import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pps/core/supabase/supabase_client_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

enum RmsBridgeSupabaseSyncMode { codeBased, keyBased }

class RmsBridgeSupabaseSyncTarget {
  final String tableName;
  final RmsBridgeSupabaseSyncMode mode;
  final String identifierField;
  final String labelField;
  final String codeField;
  final String nameField;

  const RmsBridgeSupabaseSyncTarget({
    required this.tableName,
    required this.mode,
    this.identifierField = 'key',
    this.labelField = 'label',
    this.codeField = 'code',
    this.nameField = 'name',
  });
}

class RmsBridgeSupabaseSyncCandidate {
  final String key;
  final String? code;
  final String name;
  final String label;

  const RmsBridgeSupabaseSyncCandidate({
    required this.key,
    required this.code,
    required this.name,
    required this.label,
  });
}

class RmsBridgeSupabaseSyncRequest {
  final RmsBridgeSupabaseSyncTarget target;
  final List<RmsBridgeSupabaseSyncCandidate> candidates;

  const RmsBridgeSupabaseSyncRequest({
    required this.target,
    required this.candidates,
  });
}

enum RmsBridgeSupabaseSyncAction { insert, update }

class RmsBridgeSupabaseSyncPlannedItem {
  final String name;
  final String? identifier;
  final RmsBridgeSupabaseSyncAction action;
  final String? existingName;

  const RmsBridgeSupabaseSyncPlannedItem({
    required this.name,
    required this.identifier,
    required this.action,
    required this.existingName,
  });
}

class RmsBridgeSupabaseSyncIssueItem {
  final String name;
  final String? identifier;
  final String reason;

  const RmsBridgeSupabaseSyncIssueItem({
    required this.name,
    required this.identifier,
    required this.reason,
  });
}

class RmsBridgeSupabaseSyncPreview {
  final String tableName;
  final bool isSupabaseConfigured;
  final String? configurationIssue;
  final String lastSyncUser;
  final DateTime? lastSyncAt;
  final DateTime? latestRowCreatedAt;
  final int rmsItemsCount;
  final int supabaseItemsCount;
  final int insertCount;
  final int updateCount;
  final int skipCount;
  final int conflictsCount;
  final int nullCodesCount;
  final int duplicateCodesCount;
  final List<RmsBridgeSupabaseSyncPlannedItem> pendingItems;
  final List<RmsBridgeSupabaseSyncIssueItem> issueItems;

  const RmsBridgeSupabaseSyncPreview({
    required this.tableName,
    required this.isSupabaseConfigured,
    required this.configurationIssue,
    required this.lastSyncUser,
    required this.lastSyncAt,
    required this.latestRowCreatedAt,
    required this.rmsItemsCount,
    required this.supabaseItemsCount,
    required this.insertCount,
    required this.updateCount,
    required this.skipCount,
    required this.conflictsCount,
    required this.nullCodesCount,
    required this.duplicateCodesCount,
    required this.pendingItems,
    required this.issueItems,
  });

  int get pendingCount => pendingItems.length;

  bool get isCodeUniqueLikely => duplicateCodesCount == 0;
}

final rmsBridgeSupabaseSyncPreviewProvider = FutureProvider.autoDispose
    .family<RmsBridgeSupabaseSyncPreview, RmsBridgeSupabaseSyncRequest>((
      ref,
      request,
    ) async {
      final baseConfigIssue = supabaseUrl.trim().isEmpty
          ? 'SUPABASE_URL is missing.'
          : (supabaseAnonKey.trim().isEmpty
                ? 'SUPABASE_ANON_KEY is missing.'
                : null);
      var configurationIssue = baseConfigIssue;
      var configured = isSupabaseConfigured && baseConfigIssue == null;

      final supabaseClient = ref.watch(supabaseClientProvider);
      if (configured && supabaseClient == null) {
        configurationIssue = 'Supabase client is not initialized.';
        configured = false;
      }

      final target = request.target;
      final normalized = <RmsBridgeSupabaseSyncCandidate>[];
      for (final item in request.candidates) {
        final key = item.key.trim();
        final code = item.code?.trim();
        final name = item.name.trim();
        final label = item.label.trim();
        if (key.isEmpty) continue;
        if (name.isEmpty && label.isEmpty) continue;
        normalized.add(
          RmsBridgeSupabaseSyncCandidate(
            key: key,
            code: code,
            name: name.isEmpty ? label : name,
            label: label.isEmpty ? name : label,
          ),
        );
      }

      final rmsCount = normalized.length;

      var supabaseCount = 0;
      var nullCodesCount = 0;
      var duplicateCodesCount = 0;
      DateTime? latestRowCreatedAt;

      Map<String, Map<String, dynamic>> existingByIdentifier =
          const <String, Map<String, dynamic>>{};

      if (configured) {
        try {
          supabaseCount = await _fetchCount(
            supabaseClient!,
            target: target,
          ).timeout(const Duration(seconds: 10));
          latestRowCreatedAt = await _fetchLatestCreatedAt(
            supabaseClient,
            tableName: target.tableName,
          ).timeout(const Duration(seconds: 10));
          nullCodesCount = await _fetchNullCodesCount(
            supabaseClient,
            target: target,
          ).timeout(const Duration(seconds: 10));
          duplicateCodesCount = await _fetchDuplicateCodesCount(
            supabaseClient,
            target: target,
          ).timeout(const Duration(seconds: 10));

          existingByIdentifier = await _fetchExistingByIdentifier(
            supabaseClient,
            target: target,
            candidates: normalized,
          ).timeout(const Duration(seconds: 10));
        } on TimeoutException {
          configurationIssue = 'Supabase request timed out.';
          configured = false;
        } catch (e) {
          configurationIssue = _formatSupabasePreviewError(e, target.tableName);
          configured = false;
        }
      }

      final pending = <RmsBridgeSupabaseSyncPlannedItem>[];
      final issues = <RmsBridgeSupabaseSyncIssueItem>[];
      var insertCount = 0;
      var updateCount = 0;
      var skipCount = 0;
      var conflictsCount = 0;

      if (target.mode == RmsBridgeSupabaseSyncMode.codeBased) {
        final seenCodes = <String>{};
        final seenNames = <String>{};
        for (final item in normalized) {
          final code = (item.code ?? '').trim();
          final name = item.name.trim();
          if (code.isNotEmpty) {
            if (!seenCodes.add(code)) {
              conflictsCount += 1;
              issues.add(
                RmsBridgeSupabaseSyncIssueItem(
                  name: name,
                  identifier: code,
                  reason: 'Duplicate code in source list.',
                ),
              );
              continue;
            }
            final existing = existingByIdentifier[code];
            if (existing == null) {
              insertCount += 1;
              pending.add(
                RmsBridgeSupabaseSyncPlannedItem(
                  name: name,
                  identifier: code,
                  action: RmsBridgeSupabaseSyncAction.insert,
                  existingName: null,
                ),
              );
              continue;
            }

            final existingName = existing['name']?.toString().trim();
            if ((existingName ?? '') == name) {
              skipCount += 1;
              continue;
            }
            updateCount += 1;
            pending.add(
              RmsBridgeSupabaseSyncPlannedItem(
                name: name,
                identifier: code,
                action: RmsBridgeSupabaseSyncAction.update,
                existingName: existingName,
              ),
            );
            continue;
          }

          final nameKey = name.toLowerCase();
          if (!seenNames.add(nameKey)) {
            conflictsCount += 1;
            issues.add(
              RmsBridgeSupabaseSyncIssueItem(
                name: name,
                identifier: null,
                reason: 'Duplicate name without code in source list.',
              ),
            );
            continue;
          }
          insertCount += 1;
          pending.add(
            RmsBridgeSupabaseSyncPlannedItem(
              name: name,
              identifier: null,
              action: RmsBridgeSupabaseSyncAction.insert,
              existingName: null,
            ),
          );
        }
      } else {
        final seenKeys = <String>{};
        for (final item in normalized) {
          final key = item.key.trim();
          final label = item.label.trim();
          if (!seenKeys.add(key)) {
            conflictsCount += 1;
            issues.add(
              RmsBridgeSupabaseSyncIssueItem(
                name: label,
                identifier: key,
                reason: 'Duplicate key in source list.',
              ),
            );
            continue;
          }
          final existing = existingByIdentifier[key];
          if (existing == null) {
            insertCount += 1;
            pending.add(
              RmsBridgeSupabaseSyncPlannedItem(
                name: label,
                identifier: key,
                action: RmsBridgeSupabaseSyncAction.insert,
                existingName: null,
              ),
            );
            continue;
          }

          final existingLabel = existing[target.labelField]?.toString().trim();
          final existingCode = (existing[target.codeField] as String?)?.trim();
          final incomingCode = (item.code ?? '').trim();
          final sameLabel = (existingLabel ?? '') == label;
          final sameCode = (existingCode ?? '').isEmpty
              ? incomingCode.isEmpty
              : existingCode == incomingCode;
          if (sameLabel && sameCode) {
            skipCount += 1;
            continue;
          }
          updateCount += 1;
          pending.add(
            RmsBridgeSupabaseSyncPlannedItem(
              name: label,
              identifier: key,
              action: RmsBridgeSupabaseSyncAction.update,
              existingName: existingLabel,
            ),
          );
        }
      }

      return RmsBridgeSupabaseSyncPreview(
        tableName: target.tableName,
        isSupabaseConfigured: configured,
        configurationIssue: configurationIssue,
        lastSyncUser: 'PPS User (placeholder)',
        lastSyncAt: null,
        latestRowCreatedAt: latestRowCreatedAt,
        rmsItemsCount: rmsCount,
        supabaseItemsCount: supabaseCount,
        insertCount: insertCount,
        updateCount: updateCount,
        skipCount: skipCount,
        conflictsCount: conflictsCount,
        nullCodesCount: nullCodesCount,
        duplicateCodesCount: duplicateCodesCount,
        pendingItems: pending,
        issueItems: issues,
      );
    });

class RmsBridgeSupabaseSyncApplyState {
  static const _unset = Object();

  final bool isSyncing;
  final String? errorMessage;
  final RmsBridgeSupabaseSyncApplyResult? lastResult;

  const RmsBridgeSupabaseSyncApplyState({
    this.isSyncing = false,
    this.errorMessage,
    this.lastResult,
  });

  RmsBridgeSupabaseSyncApplyState copyWith({
    bool? isSyncing,
    Object? errorMessage = _unset,
    Object? lastResult = _unset,
  }) {
    return RmsBridgeSupabaseSyncApplyState(
      isSyncing: isSyncing ?? this.isSyncing,
      errorMessage: errorMessage == _unset
          ? this.errorMessage
          : errorMessage as String?,
      lastResult: lastResult == _unset
          ? this.lastResult
          : lastResult as RmsBridgeSupabaseSyncApplyResult?,
    );
  }
}

class RmsBridgeSupabaseSyncApplyResult {
  final int inserted;
  final int updated;
  final int skipped;
  final int errors;
  final List<String> sampleErrors;
  final List<RmsBridgeSupabaseSyncApplyFailureItem> failureItems;

  const RmsBridgeSupabaseSyncApplyResult({
    required this.inserted,
    required this.updated,
    required this.skipped,
    required this.errors,
    required this.sampleErrors,
    required this.failureItems,
  });
}

class RmsBridgeSupabaseSyncApplyFailureItem {
  final String name;
  final String? identifier;
  final String message;

  const RmsBridgeSupabaseSyncApplyFailureItem({
    required this.name,
    required this.identifier,
    required this.message,
  });
}

final rmsBridgeSupabaseSyncApplyProvider =
    NotifierProvider.autoDispose<
      RmsBridgeSupabaseSyncApplyNotifier,
      RmsBridgeSupabaseSyncApplyState
    >(RmsBridgeSupabaseSyncApplyNotifier.new);

class RmsBridgeSupabaseSyncApplyNotifier
    extends Notifier<RmsBridgeSupabaseSyncApplyState> {
  @override
  RmsBridgeSupabaseSyncApplyState build() =>
      const RmsBridgeSupabaseSyncApplyState();

  Future<RmsBridgeSupabaseSyncApplyResult?> apply(
    RmsBridgeSupabaseSyncRequest request,
  ) async {
    state = state.copyWith(isSyncing: true, errorMessage: null);
    try {
      final client = ref.read(supabaseClientProvider);
      if (client == null) {
        const message =
            'Supabase is not configured. Add SUPABASE_URL and SUPABASE_ANON_KEY.';
        state = state.copyWith(isSyncing: false, errorMessage: message);
        return null;
      }

      final result =
          await (request.target.mode == RmsBridgeSupabaseSyncMode.codeBased
              ? _importCodeBased(
                  client,
                  target: request.target,
                  candidates: request.candidates,
                )
              : _importKeyBased(
                  client,
                  target: request.target,
                  candidates: request.candidates,
                ));
      state = state.copyWith(
        isSyncing: false,
        errorMessage: null,
        lastResult: result,
      );
      return result;
    } catch (e) {
      final message = e.toString();
      state = state.copyWith(isSyncing: false, errorMessage: message);
      return null;
    }
  }
}

Future<int> _fetchCount(
  SupabaseClient client, {
  required RmsBridgeSupabaseSyncTarget target,
}) async {
  final selectColumn = target.mode == RmsBridgeSupabaseSyncMode.codeBased
      ? 'id'
      : target.identifierField;
  final response = await client
      .from(target.tableName)
      .select(selectColumn)
      .count(CountOption.exact);
  return response.count;
}

Future<DateTime?> _fetchLatestCreatedAt(
  SupabaseClient client, {
  required String tableName,
}) async {
  try {
    final result = await client
        .from(tableName)
        .select('created_at')
        .order('created_at', ascending: false)
        .limit(1);
    final rows = result as List<dynamic>;
    if (rows.isEmpty) return null;
    final createdAt = (rows.first as Map<String, dynamic>)['created_at'];
    final iso = createdAt?.toString().trim();
    if (iso == null || iso.isEmpty) return null;
    return DateTime.tryParse(iso);
  } catch (_) {
    return null;
  }
}

Future<int> _fetchNullCodesCount(
  SupabaseClient client, {
  required RmsBridgeSupabaseSyncTarget target,
}) async {
  try {
    final selectColumn = target.mode == RmsBridgeSupabaseSyncMode.codeBased
        ? 'id'
        : target.identifierField;
    final response = await client
        .from(target.tableName)
        .select(selectColumn)
        .isFilter(target.codeField, null)
        .count(CountOption.exact);
    return response.count;
  } catch (_) {
    return 0;
  }
}

Future<int> _fetchDuplicateCodesCount(
  SupabaseClient client, {
  required RmsBridgeSupabaseSyncTarget target,
}) async {
  try {
    final result = await client
        .from(target.tableName)
        .select(target.codeField)
        .not(target.codeField, 'is', null)
        .range(0, 999);
    final seen = <String>{};
    final duplicates = <String>{};
    for (final row in (result as List<dynamic>)) {
      final code = (row as Map<String, dynamic>)[target.codeField]
          ?.toString()
          .trim();
      if (code == null || code.isEmpty) continue;
      if (!seen.add(code)) duplicates.add(code);
    }
    return duplicates.length;
  } catch (_) {
    return 0;
  }
}

Future<Map<String, Map<String, dynamic>>> _fetchExistingByIdentifier(
  SupabaseClient client, {
  required RmsBridgeSupabaseSyncTarget target,
  required List<RmsBridgeSupabaseSyncCandidate> candidates,
}) async {
  if (target.mode == RmsBridgeSupabaseSyncMode.codeBased) {
    final codes = <String>{
      for (final item in candidates)
        if ((item.code ?? '').trim().isNotEmpty) (item.code ?? '').trim(),
    };
    if (codes.isEmpty) return const <String, Map<String, dynamic>>{};
    final result = await client
        .from(target.tableName)
        .select('id,${target.codeField},${target.nameField}')
        .inFilter(target.codeField, codes.toList(growable: false));
    final map = <String, Map<String, dynamic>>{};
    for (final row in (result as List<dynamic>)) {
      final asMap = Map<String, dynamic>.from(row as Map);
      final code = (asMap[target.codeField] as String?)?.trim();
      if (code == null || code.isEmpty) continue;
      map[code] = asMap;
    }
    return map;
  }

  final identifiers = <String>{for (final item in candidates) item.key.trim()};
  if (identifiers.isEmpty) return const <String, Map<String, dynamic>>{};
  final filterValues = <Object>[
    for (final value in identifiers) _coerceIdentifierValue(value, target),
  ];
  final result = await client
      .from(target.tableName)
      .select(
        '${target.identifierField},${target.labelField},${target.codeField}',
      )
      .inFilter(target.identifierField, filterValues);
  final map = <String, Map<String, dynamic>>{};
  for (final row in (result as List<dynamic>)) {
    final asMap = Map<String, dynamic>.from(row as Map);
    final raw = asMap[target.identifierField];
    final id = raw?.toString().trim();
    if (id == null || id.isEmpty) continue;
    map[id] = asMap;
  }
  return map;
}

Object _coerceIdentifierValue(String raw, RmsBridgeSupabaseSyncTarget target) {
  if (target.identifierField == 'id') {
    final parsed = int.tryParse(raw.trim());
    if (parsed != null) return parsed;
  }
  return raw.trim();
}

bool _isSameValue(Object? a, Object? b) {
  final left = a?.toString().trim() ?? '';
  final right = b?.toString().trim() ?? '';
  return left == right;
}

Future<RmsBridgeSupabaseSyncApplyResult> _importCodeBased(
  SupabaseClient client, {
  required RmsBridgeSupabaseSyncTarget target,
  required List<RmsBridgeSupabaseSyncCandidate> candidates,
}) async {
  final rows = <Map<String, dynamic>>[];
  for (final item in candidates) {
    final name = item.name.trim();
    final code = item.code?.trim();
    if (name.isEmpty) continue;
    rows.add(<String, dynamic>{
      target.nameField: name,
      if (code != null && code.isNotEmpty) target.codeField: code,
    });
  }
  if (rows.isEmpty) {
    return const RmsBridgeSupabaseSyncApplyResult(
      inserted: 0,
      updated: 0,
      skipped: 0,
      errors: 0,
      sampleErrors: [],
      failureItems: [],
    );
  }

  final codes = <String>{
    for (final row in rows)
      if ((row[target.codeField] as String?)?.trim().isNotEmpty ?? false)
        (row[target.codeField] as String).trim(),
  };
  final existingByCode = await _fetchExistingByIdentifier(
    client,
    target: target,
    candidates: [
      for (final code in codes)
        RmsBridgeSupabaseSyncCandidate(
          key: code,
          code: code,
          name: code,
          label: code,
        ),
    ],
  );
  final seenCodes = <String>{};

  var inserted = 0;
  var updated = 0;
  var skipped = 0;
  var errors = 0;
  final sampleErrors = <String>[];
  final failureItems = <RmsBridgeSupabaseSyncApplyFailureItem>[];

  for (final row in rows) {
    final code = (row[target.codeField] as String?)?.trim();
    final name = (row[target.nameField] as String?)?.trim() ?? '';
    try {
      if (code == null || code.isEmpty) {
        final insertedRows = await client
            .from(target.tableName)
            .insert(row)
            .select('id');
        inserted += (insertedRows as List<dynamic>).length;
        continue;
      }

      if (!seenCodes.add(code)) {
        skipped += 1;
        continue;
      }

      final existing = existingByCode[code];
      if (existing == null) {
        try {
          final insertedRows = await client
              .from(target.tableName)
              .insert(row)
              .select('id');
          inserted += (insertedRows as List<dynamic>).length;
        } on PostgrestException catch (e) {
          if (_looksLikeDuplicateKey(e)) {
            final updatedRows = await client
                .from(target.tableName)
                .update(row)
                .eq(target.codeField, code)
                .select('id');
            final updatedCount = (updatedRows as List<dynamic>).length;
            if (updatedCount == 0) {
              skipped += 1;
              errors += 1;
              if (sampleErrors.length < 5) {
                sampleErrors.add(
                  'Duplicate code exists but update matched 0 rows (code=$code). Check RLS/policies for public.${target.tableName}. Insert error: ${e.message}',
                );
              }
              if (failureItems.length < 30) {
                failureItems.add(
                  RmsBridgeSupabaseSyncApplyFailureItem(
                    name: name.isEmpty ? '—' : name,
                    identifier: code,
                    message: e.message,
                  ),
                );
              }
            } else {
              updated += updatedCount;
            }
          } else {
            rethrow;
          }
        }
        continue;
      }

      if (_isSameValue(row[target.nameField], existing[target.nameField]) &&
          _isSameValue(row[target.codeField], existing[target.codeField])) {
        skipped += 1;
        continue;
      }

      final id = existing['id'];
      final filterField = id == null ? target.codeField : 'id';
      final filterValue = id ?? code;
      final updatedRows = await client
          .from(target.tableName)
          .update(row)
          .eq(filterField, filterValue)
          .select('id');
      final updatedCount = (updatedRows as List<dynamic>).length;
      if (updatedCount == 0) {
        skipped += 1;
        continue;
      }
      updated += updatedCount;
    } on PostgrestException catch (e) {
      errors += 1;
      if (sampleErrors.length < 5) sampleErrors.add('Postgrest: ${e.message}');
      if (failureItems.length < 30) {
        failureItems.add(
          RmsBridgeSupabaseSyncApplyFailureItem(
            name: name.isEmpty ? '—' : name,
            identifier: code,
            message: 'Postgrest: ${e.message}',
          ),
        );
      }
    } catch (e) {
      errors += 1;
      if (sampleErrors.length < 5) sampleErrors.add(e.toString());
      if (failureItems.length < 30) {
        failureItems.add(
          RmsBridgeSupabaseSyncApplyFailureItem(
            name: name.isEmpty ? '—' : name,
            identifier: code,
            message: e.toString(),
          ),
        );
      }
    }
  }

  return RmsBridgeSupabaseSyncApplyResult(
    inserted: inserted,
    updated: updated,
    skipped: skipped,
    errors: errors,
    sampleErrors: sampleErrors,
    failureItems: failureItems,
  );
}

Future<RmsBridgeSupabaseSyncApplyResult> _importKeyBased(
  SupabaseClient client, {
  required RmsBridgeSupabaseSyncTarget target,
  required List<RmsBridgeSupabaseSyncCandidate> candidates,
}) async {
  final rows = <Map<String, dynamic>>[];
  for (final item in candidates) {
    final key = item.key.trim();
    final label = item.label.trim();
    final code = item.code?.trim();
    if (key.isEmpty || label.isEmpty) continue;
    rows.add(<String, dynamic>{
      target.identifierField: _coerceIdentifierValue(key, target),
      target.labelField: label,
      if (code != null && code.isNotEmpty) target.codeField: code,
    });
  }
  if (rows.isEmpty) {
    return const RmsBridgeSupabaseSyncApplyResult(
      inserted: 0,
      updated: 0,
      skipped: 0,
      errors: 0,
      sampleErrors: [],
      failureItems: [],
    );
  }

  final keys = <String>{for (final item in candidates) item.key.trim()};
  final existingByKey = await _fetchExistingByIdentifier(
    client,
    target: target,
    candidates: [
      for (final key in keys)
        RmsBridgeSupabaseSyncCandidate(
          key: key,
          code: null,
          name: key,
          label: key,
        ),
    ],
  );

  final seenKeys = <String>{};
  var inserted = 0;
  var updated = 0;
  var skipped = 0;
  var errors = 0;
  final sampleErrors = <String>[];
  final failureItems = <RmsBridgeSupabaseSyncApplyFailureItem>[];

  for (final row in rows) {
    final rawIdentifier = row[target.identifierField];
    final key = rawIdentifier?.toString().trim();
    final label = (row[target.labelField] as String?)?.trim() ?? '';
    try {
      if (key == null || key.isEmpty) {
        skipped += 1;
        continue;
      }
      if (!seenKeys.add(key)) {
        skipped += 1;
        continue;
      }

      final existing = existingByKey[key];
      if (existing == null) {
        final insertedRows = await client
            .from(target.tableName)
            .insert(row)
            .select(target.identifierField);
        inserted += (insertedRows as List<dynamic>).length;
        continue;
      }

      if (_isSameValue(row[target.labelField], existing[target.labelField]) &&
          _isSameValue(row[target.codeField], existing[target.codeField])) {
        skipped += 1;
        continue;
      }

      final updatedRows = await client
          .from(target.tableName)
          .update(row)
          .eq(target.identifierField, _coerceIdentifierValue(key, target))
          .select(target.identifierField);
      final updatedCount = (updatedRows as List<dynamic>).length;
      if (updatedCount == 0) {
        skipped += 1;
        continue;
      }
      updated += updatedCount;
    } on PostgrestException catch (e) {
      errors += 1;
      if (sampleErrors.length < 5) sampleErrors.add('Postgrest: ${e.message}');
      if (failureItems.length < 30) {
        failureItems.add(
          RmsBridgeSupabaseSyncApplyFailureItem(
            name: label.isEmpty ? '—' : label,
            identifier: key,
            message: 'Postgrest: ${e.message}',
          ),
        );
      }
    } catch (e) {
      errors += 1;
      if (sampleErrors.length < 5) sampleErrors.add(e.toString());
      if (failureItems.length < 30) {
        failureItems.add(
          RmsBridgeSupabaseSyncApplyFailureItem(
            name: label.isEmpty ? '—' : label,
            identifier: key,
            message: e.toString(),
          ),
        );
      }
    }
  }

  return RmsBridgeSupabaseSyncApplyResult(
    inserted: inserted,
    updated: updated,
    skipped: skipped,
    errors: errors,
    sampleErrors: sampleErrors,
    failureItems: failureItems,
  );
}

bool _looksLikeDuplicateKey(PostgrestException e) {
  final lower = e.message.toLowerCase();
  return lower.contains('duplicate key value') ||
      lower.contains('unique constraint') ||
      lower.contains('already exists');
}

String _formatSupabasePreviewError(Object e, String tableName) {
  if (e is PostgrestException) {
    if (e.code == 'PGRST205' ||
        e.message.toLowerCase().contains("could not find the table")) {
      return "Supabase error: missing table public.$tableName. Create the table or update the mapping.";
    }
    return 'Supabase error: PostgrestException(message: ${e.message}, code: ${e.code}, details: ${e.details}, hint: ${e.hint})';
  }
  return 'Supabase error: $e';
}
