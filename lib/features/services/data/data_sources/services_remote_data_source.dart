import 'package:supabase_flutter/supabase_flutter.dart';

class ServicesRemoteDataSource {
  ServicesRemoteDataSource({required SupabaseClient? supabaseClient})
    : _supabaseClient = supabaseClient;

  final SupabaseClient? _supabaseClient;

  Future<Map<String, dynamic>> createReservationServiceType({
    required String keyValue,
    String? label,
    String? code,
  }) async {
    final client = _requireClient();
    final normalizedKey = keyValue.trim();
    final normalizedLabel = label?.trim();
    final normalizedCode = code?.trim();

    final payload = <String, dynamic>{
      'key': normalizedKey,
      if (normalizedLabel != null && normalizedLabel.isNotEmpty)
        'label': normalizedLabel,
      if (normalizedCode != null && normalizedCode.isNotEmpty)
        'code': normalizedCode,
    };

    final created = await client
        .from('reservation_service_types')
        .insert(payload)
        .select('id,key,label,code')
        .single();
    return Map<String, dynamic>.from(created as Map);
  }

  bool _looksLikeDuplicateKey(String message) {
    final lower = message.toLowerCase();
    return lower.contains('duplicate key value') ||
        lower.contains('unique constraint') ||
        lower.contains('already exists');
  }

  String _duplicateConflictField(PostgrestException e) {
    final message = e.message.toLowerCase();
    final details = (e.details?.toString() ?? '').toLowerCase();
    final combined = '$message $details';

    if (combined.contains('key (id)=') ||
        combined.contains('reservation_service_types_pkey')) {
      return 'id';
    }
    if (combined.contains('key (key)=') ||
        combined.contains('reservation_service_types_key') ||
        combined.contains('key_unique')) {
      return 'key';
    }
    return 'unknown';
  }

  String _formatPostgrest(PostgrestException e) {
    final details = e.details?.toString();
    final hint = e.hint?.toString();
    final parts = <String>[e.message];
    if (details != null && details.trim().isNotEmpty) {
      parts.add('details=$details');
    }
    if (hint != null && hint.trim().isNotEmpty) {
      parts.add('hint=$hint');
    }
    return parts.join(' | ');
  }

  Future<Set<String>> findExistingReservationServiceTypeKeys(
    Iterable<String> keys,
  ) async {
    final normalized = keys
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toSet();
    if (normalized.isEmpty) return const <String>{};

    final client = _requireClient();
    final result = await client
        .from('reservation_service_types')
        .select('key')
        .inFilter('key', normalized.toList(growable: false));

    final found = <String>{};
    for (final row in (result as List<dynamic>)) {
      final keyValue = (row as Map<String, dynamic>)['key']?.toString().trim();
      if (keyValue != null && keyValue.isNotEmpty) found.add(keyValue);
    }
    return found;
  }

  Future<ServicesBulkImportResult> importReservationServiceTypes(
    List<Map<String, dynamic>> rows,
  ) async {
    if (rows.isEmpty) {
      return const ServicesBulkImportResult(
        inserted: 0,
        updated: 0,
        skipped: 0,
        errors: 0,
        sampleErrors: [],
        sampleInsertedKeys: [],
        sampleUpdatedKeys: [],
        sampleSkippedKeys: [],
      );
    }

    final client = _requireClient();
    final keys = <String>{
      for (final row in rows)
        if ((row['key'] as String?)?.trim().isNotEmpty ?? false)
          (row['key'] as String).trim(),
    };

    final existingByKey = await _fetchExistingByKey(client, keys);
    final seenKeys = <String>{};

    var inserted = 0;
    var updated = 0;
    var skipped = 0;
    var errors = 0;
    final sampleErrors = <String>[];
    final sampleInsertedKeys = <String>[];
    final sampleUpdatedKeys = <String>[];
    final sampleSkippedKeys = <String>[];

    for (final row in rows) {
      try {
        final keyValue = (row['key'] as String?)?.trim();
        if (keyValue == null || keyValue.isEmpty) {
          final insertedRows = await client
              .from('reservation_service_types')
              .insert(row)
              .select('key');
          inserted += (insertedRows as List<dynamic>).length;
          continue;
        }

        if (!seenKeys.add(keyValue)) {
          skipped += 1;
          if (sampleSkippedKeys.length < 20) {
            sampleSkippedKeys.add('$keyValue (duplicate in file)');
          }
          continue;
        }

        final existing = existingByKey[keyValue];
        if (existing == null) {
          try {
            final insertedRows = await client
                .from('reservation_service_types')
                .insert(row)
                .select('key');
            inserted += (insertedRows as List<dynamic>).length;
            if (sampleInsertedKeys.length < 20) {
              sampleInsertedKeys.add(keyValue);
            }
          } on PostgrestException catch (e) {
            if (_looksLikeDuplicateKey(e.message)) {
              final conflictField = _duplicateConflictField(e);
              if (conflictField == 'id' || conflictField == 'unknown') {
                errors += 1;
                if (sampleErrors.length < 5) {
                  sampleErrors.add(
                    'Duplicate primary key while inserting service type (key=$keyValue): ${_formatPostgrest(e)}',
                  );
                }
                continue;
              }

              try {
                final updatedRows = await client
                    .from('reservation_service_types')
                    .update(row)
                    .eq('key', keyValue)
                    .select('key');
                final updatedCount = (updatedRows as List<dynamic>).length;
                if (updatedCount == 0) {
                  skipped += 1;
                  if (sampleSkippedKeys.length < 20) {
                    sampleSkippedKeys.add('$keyValue (exists; not updated)');
                  }
                  if (sampleErrors.length < 5) {
                    sampleErrors.add(
                      'Duplicate key exists but update matched 0 rows (key=$keyValue). Check RLS/policies for public.reservation_service_types. Insert error: ${_formatPostgrest(e)}',
                    );
                  }
                } else {
                  updated += updatedCount;
                  if (sampleUpdatedKeys.length < 20) {
                    sampleUpdatedKeys.add(keyValue);
                  }
                }
              } on PostgrestException catch (updateError) {
                skipped += 1;
                if (sampleSkippedKeys.length < 20) {
                  sampleSkippedKeys.add('$keyValue (exists; update denied)');
                }
                if (sampleErrors.length < 5) {
                  sampleErrors.add(
                    'Duplicate key exists but update failed (key=$keyValue): ${_formatPostgrest(updateError)}. Insert error: ${_formatPostgrest(e)}',
                  );
                }
              }
            } else {
              rethrow;
            }
          }
          continue;
        }

        if (_isSameRow(row, existing, keyField: 'key')) {
          skipped += 1;
          if (sampleSkippedKeys.length < 20) {
            sampleSkippedKeys.add('$keyValue (no changes)');
          }
          continue;
        }

        final updatedRows = await client
            .from('reservation_service_types')
            .update(row)
            .eq('key', keyValue)
            .select('key');
        final updatedCount = (updatedRows as List<dynamic>).length;
        if (updatedCount == 0) {
          errors += 1;
          if (sampleErrors.length < 5) {
            sampleErrors.add('Update returned 0 rows for key=$keyValue');
          }
          continue;
        }
        updated += updatedCount;
        if (sampleUpdatedKeys.length < 20) sampleUpdatedKeys.add(keyValue);
      } on PostgrestException catch (e) {
        errors += 1;
        if (sampleErrors.length < 5) {
          sampleErrors.add('Postgrest: ${e.message}');
        }
      } catch (e) {
        errors += 1;
        if (sampleErrors.length < 5) {
          sampleErrors.add(e.toString());
        }
      }
    }

    return ServicesBulkImportResult(
      inserted: inserted,
      updated: updated,
      skipped: skipped,
      errors: errors,
      sampleErrors: sampleErrors,
      sampleInsertedKeys: sampleInsertedKeys,
      sampleUpdatedKeys: sampleUpdatedKeys,
      sampleSkippedKeys: sampleSkippedKeys,
    );
  }

  Future<Map<String, Map<String, dynamic>>> _fetchExistingByKey(
    SupabaseClient client,
    Set<String> keys,
  ) async {
    if (keys.isEmpty) return const <String, Map<String, dynamic>>{};

    final result = await client
        .from('reservation_service_types')
        .select('key,label,code')
        .inFilter('key', keys.toList(growable: false));

    final mapped = <String, Map<String, dynamic>>{};
    for (final row in (result as List<dynamic>)) {
      final map = row as Map<String, dynamic>;
      final keyValue = map['key']?.toString().trim();
      if (keyValue == null || keyValue.isEmpty) continue;
      mapped.putIfAbsent(keyValue, () => map);
    }
    return mapped;
  }

  bool _isSameRow(
    Map<String, dynamic> incoming,
    Map<String, dynamic> existing, {
    required String keyField,
  }) {
    for (final entry in incoming.entries) {
      if (entry.key == keyField) continue;
      if (!_isSameValue(entry.value, existing[entry.key])) return false;
    }
    return true;
  }

  bool _isSameValue(dynamic a, dynamic b) {
    final aNorm = _normalizeValue(a);
    final bNorm = _normalizeValue(b);
    return aNorm == bNorm;
  }

  String? _normalizeValue(dynamic input) {
    if (input == null) return null;
    final str = input.toString().trim();
    if (str.isEmpty) return null;
    return str;
  }

  SupabaseClient _requireClient() {
    final client = _supabaseClient;
    if (client == null) {
      throw const ServicesDataSourceException(
        'Supabase is not configured. Add SUPABASE_URL and SUPABASE_ANON_KEY.',
      );
    }
    return client;
  }
}

class ServicesBulkImportResult {
  final int inserted;
  final int updated;
  final int skipped;
  final int errors;
  final List<String> sampleErrors;
  final List<String> sampleInsertedKeys;
  final List<String> sampleUpdatedKeys;
  final List<String> sampleSkippedKeys;

  const ServicesBulkImportResult({
    required this.inserted,
    required this.updated,
    required this.skipped,
    required this.errors,
    required this.sampleErrors,
    required this.sampleInsertedKeys,
    required this.sampleUpdatedKeys,
    required this.sampleSkippedKeys,
  });
}

class ServicesDataSourceException implements Exception {
  const ServicesDataSourceException(this.message);

  final String message;

  @override
  String toString() => message;
}
