import 'package:supabase_flutter/supabase_flutter.dart';

class HotelsRemoteDataSource {
  HotelsRemoteDataSource({required SupabaseClient? supabaseClient})
    : _supabaseClient = supabaseClient;

  final SupabaseClient? _supabaseClient;

  Future<Map<String, dynamic>> createHotel({
    required String name,
    String? code,
    String? city,
    String? category,
    int? supplierId,
  }) async {
    final client = _requireClient();
    final normalizedName = name.trim();
    final normalizedCode = code?.trim();
    final normalizedCity = city?.trim();
    final normalizedCategory = category?.trim();

    final payload = <String, dynamic>{
      'name': normalizedName,
      if (normalizedCode != null && normalizedCode.isNotEmpty)
        'code': normalizedCode,
      if (normalizedCity != null && normalizedCity.isNotEmpty)
        'city': normalizedCity,
      if (normalizedCategory != null && normalizedCategory.isNotEmpty)
        'category': normalizedCategory,
      if (supplierId != null) 'supplier_id': supplierId,
    };

    final created = await client
        .from('hotels')
        .insert(payload)
        .select('id,name,code,city,category,supplier_id')
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

    if (combined.contains('key (id)=') || combined.contains('hotels_pkey')) {
      return 'id';
    }
    if (combined.contains('key (code)=') ||
        combined.contains('hotels_code_unique') ||
        combined.contains('code_unique')) {
      return 'code';
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

  Future<Set<String>> findExistingHotelCodes(Iterable<String> codes) async {
    final normalized = codes
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toSet();
    if (normalized.isEmpty) return const <String>{};

    final client = _requireClient();
    final result = await client
        .from('hotels')
        .select('code')
        .inFilter('code', normalized.toList(growable: false));

    final found = <String>{};
    for (final row in (result as List<dynamic>)) {
      final code = (row as Map<String, dynamic>)['code']?.toString().trim();
      if (code != null && code.isNotEmpty) found.add(code);
    }
    return found;
  }

  Future<HotelsBulkImportResult> importHotels(
    List<Map<String, dynamic>> rows,
  ) async {
    if (rows.isEmpty) {
      return const HotelsBulkImportResult(
        inserted: 0,
        updated: 0,
        skipped: 0,
        errors: 0,
        sampleErrors: [],
        sampleInsertedCodes: [],
        sampleUpdatedCodes: [],
        sampleSkippedCodes: [],
      );
    }

    final client = _requireClient();
    final codes = <String>{
      for (final row in rows)
        if ((row['code'] as String?)?.trim().isNotEmpty ?? false)
          (row['code'] as String).trim(),
    };

    final existingByCode = await _fetchExistingByCode(client, codes);
    final seenCodes = <String>{};

    var inserted = 0;
    var updated = 0;
    var skipped = 0;
    var errors = 0;
    final sampleErrors = <String>[];
    final sampleInsertedCodes = <String>[];
    final sampleUpdatedCodes = <String>[];
    final sampleSkippedCodes = <String>[];

    for (final row in rows) {
      try {
        final code = (row['code'] as String?)?.trim();
        if (code == null || code.isEmpty) {
          final insertedRows = await client
              .from('hotels')
              .insert(row)
              .select('id');
          inserted += (insertedRows as List<dynamic>).length;
          continue;
        }

        if (!seenCodes.add(code)) {
          skipped += 1;
          if (sampleSkippedCodes.length < 20) {
            sampleSkippedCodes.add('$code (duplicate in file)');
          }
          continue;
        }

        final existing = existingByCode[code];
        if (existing == null) {
          try {
            final insertedRows = await client
                .from('hotels')
                .insert(row)
                .select('id');
            inserted += (insertedRows as List<dynamic>).length;
            if (sampleInsertedCodes.length < 20) sampleInsertedCodes.add(code);
          } on PostgrestException catch (e) {
            if (_looksLikeDuplicateKey(e.message)) {
              final conflictField = _duplicateConflictField(e);
              if (conflictField == 'id' || conflictField == 'unknown') {
                errors += 1;
                if (sampleErrors.length < 5) {
                  sampleErrors.add(
                    'Duplicate primary key while inserting hotel (code=$code): ${_formatPostgrest(e)}',
                  );
                }
                continue;
              }

              try {
                final updatedRows = await client
                    .from('hotels')
                    .update(row)
                    .eq('code', code)
                    .select('id');
                final updatedCount = (updatedRows as List<dynamic>).length;
                if (updatedCount == 0) {
                  skipped += 1;
                  if (sampleSkippedCodes.length < 20) {
                    sampleSkippedCodes.add('$code (exists; not updated)');
                  }
                  if (sampleErrors.length < 5) {
                    sampleErrors.add(
                      'Duplicate code exists but update matched 0 rows (code=$code). Check RLS/policies for public.hotels. Insert error: ${_formatPostgrest(e)}',
                    );
                  }
                } else {
                  updated += updatedCount;
                  if (sampleUpdatedCodes.length < 20) {
                    sampleUpdatedCodes.add(code);
                  }
                }
              } on PostgrestException catch (updateError) {
                skipped += 1;
                if (sampleSkippedCodes.length < 20) {
                  sampleSkippedCodes.add('$code (exists; update denied)');
                }
                if (sampleErrors.length < 5) {
                  sampleErrors.add(
                    'Duplicate code exists but update failed (code=$code): ${_formatPostgrest(updateError)}. Insert error: ${_formatPostgrest(e)}',
                  );
                }
              }
            } else {
              rethrow;
            }
          }
          continue;
        }

        if (_isSameRow(row, existing, keyField: 'code')) {
          skipped += 1;
          if (sampleSkippedCodes.length < 20) {
            sampleSkippedCodes.add('$code (no changes)');
          }
          continue;
        }

        final id = existing['id'];
        final filterField = id == null ? 'code' : 'id';
        final filterValue = id ?? code;
        final updatedRows = await client
            .from('hotels')
            .update(row)
            .eq(filterField, filterValue)
            .select('id');
        final updatedCount = (updatedRows as List<dynamic>).length;
        if (updatedCount == 0) {
          errors += 1;
          if (sampleErrors.length < 5) {
            sampleErrors.add('Update returned 0 rows for code=$code');
          }
          continue;
        }
        updated += updatedCount;
        if (sampleUpdatedCodes.length < 20) sampleUpdatedCodes.add(code);
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

    return HotelsBulkImportResult(
      inserted: inserted,
      updated: updated,
      skipped: skipped,
      errors: errors,
      sampleErrors: sampleErrors,
      sampleInsertedCodes: sampleInsertedCodes,
      sampleUpdatedCodes: sampleUpdatedCodes,
      sampleSkippedCodes: sampleSkippedCodes,
    );
  }

  Future<Map<String, Map<String, dynamic>>> _fetchExistingByCode(
    SupabaseClient client,
    Set<String> codes,
  ) async {
    if (codes.isEmpty) return const <String, Map<String, dynamic>>{};

    final result = await client
        .from('hotels')
        .select('id,code,name,city,category,supplier_id')
        .inFilter('code', codes.toList(growable: false));

    final mapped = <String, Map<String, dynamic>>{};
    for (final row in (result as List<dynamic>)) {
      final map = row as Map<String, dynamic>;
      final code = map['code']?.toString().trim();
      if (code == null || code.isEmpty) continue;
      mapped.putIfAbsent(code, () => map);
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
      throw const HotelsDataSourceException(
        'Supabase is not configured. Add SUPABASE_URL and SUPABASE_ANON_KEY.',
      );
    }
    return client;
  }
}

class HotelsBulkImportResult {
  final int inserted;
  final int updated;
  final int skipped;
  final int errors;
  final List<String> sampleErrors;
  final List<String> sampleInsertedCodes;
  final List<String> sampleUpdatedCodes;
  final List<String> sampleSkippedCodes;

  const HotelsBulkImportResult({
    required this.inserted,
    required this.updated,
    required this.skipped,
    required this.errors,
    required this.sampleErrors,
    required this.sampleInsertedCodes,
    required this.sampleUpdatedCodes,
    required this.sampleSkippedCodes,
  });
}

class HotelsDataSourceException implements Exception {
  const HotelsDataSourceException(this.message);

  final String message;

  @override
  String toString() => message;
}
