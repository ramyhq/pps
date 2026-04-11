import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pps/core/supabase/supabase_client_provider.dart';
import 'package:pps/features/clients/data/data_sources/clients_remote_data_source.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ClientSupabaseSyncCandidate {
  final String name;
  final String? code;

  const ClientSupabaseSyncCandidate({required this.name, this.code});
}

enum ClientSupabaseSyncAction { insert, update }

class ClientSupabaseSyncPlannedItem {
  final String name;
  final String? code;
  final ClientSupabaseSyncAction action;
  final String? existingName;

  const ClientSupabaseSyncPlannedItem({
    required this.name,
    required this.code,
    required this.action,
    required this.existingName,
  });
}

class ClientSupabaseSyncIssueItem {
  final String name;
  final String? code;
  final String reason;

  const ClientSupabaseSyncIssueItem({
    required this.name,
    required this.code,
    required this.reason,
  });
}

class ClientsSupabaseSyncPreview {
  final String tableName;
  final bool isSupabaseConfigured;
  final String? configurationIssue;
  final String lastSyncUser;
  final DateTime? lastSyncAt;
  final DateTime? latestRowCreatedAt;
  final int rmsItemsCount;
  final int supabaseItemsCount;
  final int matchedByCodeCount;
  final int insertCount;
  final int updateCount;
  final int skipCount;
  final int conflictsCount;
  final int nullCodesCount;
  final int duplicateCodesCount;
  final List<ClientSupabaseSyncPlannedItem> pendingItems;
  final List<ClientSupabaseSyncIssueItem> issueItems;

  const ClientsSupabaseSyncPreview({
    required this.tableName,
    required this.isSupabaseConfigured,
    required this.configurationIssue,
    required this.lastSyncUser,
    required this.lastSyncAt,
    required this.latestRowCreatedAt,
    required this.rmsItemsCount,
    required this.supabaseItemsCount,
    required this.matchedByCodeCount,
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

final clientsSupabaseRemoteDataSourceProvider =
    Provider<ClientsRemoteDataSource>((ref) {
      final supabaseClient = ref.watch(supabaseClientProvider);
      return ClientsRemoteDataSource(supabaseClient: supabaseClient);
    });

final clientsSupabaseSyncPreviewProvider = FutureProvider.autoDispose
    .family<ClientsSupabaseSyncPreview, List<ClientSupabaseSyncCandidate>>((
      ref,
      candidates,
    ) async {
      final dataSource = ref.watch(clientsSupabaseRemoteDataSourceProvider);
      final normalized = <ClientSupabaseSyncCandidate>[];
      for (final item in candidates) {
        final name = item.name.trim();
        final code = item.code?.trim();
        if (name.isEmpty) continue;
        normalized.add(ClientSupabaseSyncCandidate(name: name, code: code));
      }

      final rmsCount = normalized.length;
      final baseConfigIssue = supabaseUrl.trim().isEmpty
          ? 'SUPABASE_URL is missing.'
          : (supabaseAnonKey.trim().isEmpty
                ? 'SUPABASE_ANON_KEY is missing.'
                : null);
      var configurationIssue = baseConfigIssue;
      var configured = isSupabaseConfigured && baseConfigIssue == null;

      final codes = <String>{
        for (final item in normalized)
          if ((item.code ?? '').trim().isNotEmpty) item.code!.trim(),
      };

      final seenCodes = <String>{};
      final seenNames = <String>{};
      final pending = <ClientSupabaseSyncPlannedItem>[];
      final issues = <ClientSupabaseSyncIssueItem>[];
      var insertCount = 0;
      var updateCount = 0;
      var skipCount = 0;
      var conflictsCount = 0;

      var supabaseCount = 0;
      var matchedByCodeCount = 0;
      var nullCodesCount = 0;
      var duplicateCodesCount = 0;
      DateTime? latestRowCreatedAt;

      Map<String, Map<String, dynamic>> existingByCode =
          const <String, Map<String, dynamic>>{};

      if (configured) {
        try {
          supabaseCount = await dataSource.fetchClientsCount().timeout(
            const Duration(seconds: 10),
          );
          existingByCode = await dataSource
              .fetchExistingClientsByCode(codes)
              .timeout(const Duration(seconds: 10));
          matchedByCodeCount = existingByCode.length;
          nullCodesCount = await dataSource.fetchNullCodesCount().timeout(
            const Duration(seconds: 10),
          );
          duplicateCodesCount = await dataSource
              .fetchDuplicateCodesCount()
              .timeout(const Duration(seconds: 10));
          latestRowCreatedAt = await dataSource
              .fetchLatestClientCreatedAt()
              .timeout(const Duration(seconds: 10));
        } on TimeoutException {
          configurationIssue = 'Supabase request timed out.';
          configured = false;
        } catch (e) {
          configurationIssue = 'Supabase error: $e';
          configured = false;
        }
      }

      for (final item in normalized) {
        final code = item.code?.trim();
        if (code != null && code.isNotEmpty) {
          if (!seenCodes.add(code)) {
            conflictsCount += 1;
            issues.add(
              ClientSupabaseSyncIssueItem(
                name: item.name,
                code: code,
                reason: 'Duplicate code in source list.',
              ),
            );
            continue;
          }
          final existing = existingByCode[code];
          if (existing == null) {
            insertCount += 1;
            pending.add(
              ClientSupabaseSyncPlannedItem(
                name: item.name,
                code: code,
                action: ClientSupabaseSyncAction.insert,
                existingName: null,
              ),
            );
            continue;
          }

          final existingName = existing['name']?.toString().trim();
          if ((existingName ?? '') == item.name.trim()) {
            skipCount += 1;
            continue;
          }
          updateCount += 1;
          pending.add(
            ClientSupabaseSyncPlannedItem(
              name: item.name,
              code: code,
              action: ClientSupabaseSyncAction.update,
              existingName: existingName,
            ),
          );
          continue;
        }

        final nameKey = item.name.trim().toLowerCase();
        if (!seenNames.add(nameKey)) {
          conflictsCount += 1;
          issues.add(
            ClientSupabaseSyncIssueItem(
              name: item.name,
              code: null,
              reason: 'Duplicate name without code in source list.',
            ),
          );
          continue;
        }
        insertCount += 1;
        pending.add(
          ClientSupabaseSyncPlannedItem(
            name: item.name,
            code: null,
            action: ClientSupabaseSyncAction.insert,
            existingName: null,
          ),
        );
      }

      return ClientsSupabaseSyncPreview(
        tableName: 'clients',
        isSupabaseConfigured: configured,
        configurationIssue: configurationIssue,
        lastSyncUser: 'PPS User (placeholder)',
        lastSyncAt: null,
        latestRowCreatedAt: latestRowCreatedAt,
        rmsItemsCount: rmsCount,
        supabaseItemsCount: supabaseCount,
        matchedByCodeCount: matchedByCodeCount,
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

class ClientsSupabaseSyncApplyState {
  static const _unset = Object();

  final bool isSyncing;
  final String? errorMessage;
  final ClientsSupabaseSyncApplyResult? lastResult;

  const ClientsSupabaseSyncApplyState({
    this.isSyncing = false,
    this.errorMessage,
    this.lastResult,
  });

  ClientsSupabaseSyncApplyState copyWith({
    bool? isSyncing,
    Object? errorMessage = _unset,
    Object? lastResult = _unset,
  }) {
    return ClientsSupabaseSyncApplyState(
      isSyncing: isSyncing ?? this.isSyncing,
      errorMessage: errorMessage == _unset
          ? this.errorMessage
          : errorMessage as String?,
      lastResult: lastResult == _unset
          ? this.lastResult
          : lastResult as ClientsSupabaseSyncApplyResult?,
    );
  }
}

class ClientsSupabaseSyncApplyResult {
  final int inserted;
  final int updated;
  final int skipped;
  final int errors;
  final List<String> sampleErrors;
  final List<ClientsSupabaseSyncApplyFailureItem> failureItems;

  const ClientsSupabaseSyncApplyResult({
    required this.inserted,
    required this.updated,
    required this.skipped,
    required this.errors,
    required this.sampleErrors,
    required this.failureItems,
  });
}

class ClientsSupabaseSyncApplyFailureItem {
  final String name;
  final String? code;
  final String message;

  const ClientsSupabaseSyncApplyFailureItem({
    required this.name,
    required this.code,
    required this.message,
  });
}

final clientsSupabaseSyncApplyProvider =
    NotifierProvider.autoDispose<
      ClientsSupabaseSyncApplyNotifier,
      ClientsSupabaseSyncApplyState
    >(ClientsSupabaseSyncApplyNotifier.new);

class ClientsSupabaseSyncApplyNotifier
    extends Notifier<ClientsSupabaseSyncApplyState> {
  @override
  ClientsSupabaseSyncApplyState build() =>
      const ClientsSupabaseSyncApplyState();

  Future<ClientsSupabaseSyncApplyResult?> apply(
    List<ClientSupabaseSyncCandidate> candidates,
  ) async {
    state = state.copyWith(isSyncing: true, errorMessage: null);
    try {
      final dataSource = ref.read(clientsSupabaseRemoteDataSourceProvider);
      final rows = <Map<String, dynamic>>[];
      for (final item in candidates) {
        final name = item.name.trim();
        final code = item.code?.trim();
        if (name.isEmpty) continue;
        rows.add(<String, dynamic>{
          'name': name,
          if (code != null && code.isNotEmpty) 'code': code,
        });
      }
      final result = await dataSource.importClients(rows);
      final mapped = ClientsSupabaseSyncApplyResult(
        inserted: result.inserted,
        updated: result.updated,
        skipped: result.skipped,
        errors: result.errors,
        sampleErrors: result.sampleErrors,
        failureItems: result.failureItems
            .map(
              (e) => ClientsSupabaseSyncApplyFailureItem(
                name: e.name,
                code: e.code,
                message: e.message,
              ),
            )
            .toList(growable: false),
      );
      state = state.copyWith(
        isSyncing: false,
        errorMessage: null,
        lastResult: mapped,
      );
      return mapped;
    } on PostgrestException catch (e) {
      final message = 'Supabase error: ${e.message}';
      state = state.copyWith(isSyncing: false, errorMessage: message);
      return null;
    } catch (e) {
      final message = e.toString();
      state = state.copyWith(isSyncing: false, errorMessage: message);
      return null;
    }
  }
}
