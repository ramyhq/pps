import 'package:supabase_flutter/supabase_flutter.dart';

class ClientsRemoteDataSource {
  ClientsRemoteDataSource({required SupabaseClient? supabaseClient})
    : _supabaseClient = supabaseClient;

  final SupabaseClient? _supabaseClient;

  Future<int> fetchClientsCount() async {
    final client = _requireClient();
    final response = await client
        .from('clients')
        .select('id')
        .count(CountOption.exact);
    return response.count;
  }

  Future<DateTime?> fetchLatestClientCreatedAt() async {
    final client = _requireClient();
    final result = await client
        .from('clients')
        .select('created_at')
        .order('created_at', ascending: false)
        .limit(1);
    final rows = result as List<dynamic>;
    if (rows.isEmpty) return null;
    final createdAt = (rows.first as Map<String, dynamic>)['created_at'];
    final iso = createdAt?.toString().trim();
    if (iso == null || iso.isEmpty) return null;
    return DateTime.tryParse(iso);
  }

  Future<int> fetchNullCodesCount() async {
    final client = _requireClient();
    final response = await client
        .from('clients')
        .select('id')
        .isFilter('code', null)
        .count(CountOption.exact);
    return response.count;
  }

  Future<int> fetchDuplicateCodesCount() async {
    final client = _requireClient();
    final result = await client
        .from('clients')
        .select('code')
        .not('code', 'is', null)
        .range(0, 999);
    final seen = <String>{};
    final duplicates = <String>{};
    for (final row in (result as List<dynamic>)) {
      final code = (row as Map<String, dynamic>)['code']?.toString().trim();
      if (code == null || code.isEmpty) continue;
      if (!seen.add(code)) duplicates.add(code);
    }
    return duplicates.length;
  }

  Future<Map<String, Map<String, dynamic>>> fetchExistingClientsByCode(
    Set<String> codes,
  ) async {
    final client = _requireClient();
    return _fetchExistingByCode(client, codes);
  }

  Future<Map<String, dynamic>> createClient({
    required String name,
    String? code,
  }) async {
    final client = _requireClient();
    final normalizedName = name.trim();
    final normalizedCode = code?.trim();

    final payload = <String, dynamic>{
      'name': normalizedName,
      if (normalizedCode != null && normalizedCode.isNotEmpty)
        'code': normalizedCode,
    };

    final created = await client
        .from('clients')
        .insert(payload)
        .select('id,name,code')
        .single();
    return Map<String, dynamic>.from(created as Map);
  }

  Future<Set<String>> findExistingClientCodes(Iterable<String> codes) async {
    final normalized = codes
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toSet();
    if (normalized.isEmpty) return const <String>{};

    final client = _requireClient();
    final result = await client
        .from('clients')
        .select('code')
        .inFilter('code', normalized.toList(growable: false));

    final found = <String>{};
    for (final row in (result as List<dynamic>)) {
      final code = (row as Map<String, dynamic>)['code']?.toString().trim();
      if (code != null && code.isNotEmpty) found.add(code);
    }
    return found;
  }

  Future<ClientsBulkImportResult> importClients(
    List<Map<String, dynamic>> rows,
  ) async {
    if (rows.isEmpty) {
      return const ClientsBulkImportResult(
        inserted: 0,
        updated: 0,
        skipped: 0,
        errors: 0,
        sampleErrors: [],
        failureItems: [],
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
    final failureItems = <ClientsBulkImportFailureItem>[];
    final sampleInsertedCodes = <String>[];
    final sampleUpdatedCodes = <String>[];
    final sampleSkippedCodes = <String>[];

    for (final row in rows) {
      try {
        final code = (row['code'] as String?)?.trim();
        if (code == null || code.isEmpty) {
          final insertedRows = await client
              .from('clients')
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
          final insertedRows = await client
              .from('clients')
              .insert(row)
              .select('id');
          inserted += (insertedRows as List<dynamic>).length;
          if (sampleInsertedCodes.length < 20) sampleInsertedCodes.add(code);
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
            .from('clients')
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
        final code = (row['code'] as String?)?.trim();
        final name = (row['name'] as String?)?.trim() ?? '';
        failureItems.add(
          ClientsBulkImportFailureItem(
            name: name.isEmpty ? '—' : name,
            code: code == null || code.isEmpty ? null : code,
            message: 'Postgrest: ${e.message}',
          ),
        );
      } catch (e) {
        errors += 1;
        if (sampleErrors.length < 5) {
          sampleErrors.add(e.toString());
        }
        final code = (row['code'] as String?)?.trim();
        final name = (row['name'] as String?)?.trim() ?? '';
        failureItems.add(
          ClientsBulkImportFailureItem(
            name: name.isEmpty ? '—' : name,
            code: code == null || code.isEmpty ? null : code,
            message: e.toString(),
          ),
        );
      }
    }

    return ClientsBulkImportResult(
      inserted: inserted,
      updated: updated,
      skipped: skipped,
      errors: errors,
      sampleErrors: sampleErrors,
      failureItems: failureItems,
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
        .from('clients')
        .select('id,code,name,created_at')
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
      throw const ClientsDataSourceException(
        'Supabase is not configured. Add SUPABASE_URL and SUPABASE_ANON_KEY.',
      );
    }
    return client;
  }
}

class ClientsBulkImportResult {
  final int inserted;
  final int updated;
  final int skipped;
  final int errors;
  final List<String> sampleErrors;
  final List<ClientsBulkImportFailureItem> failureItems;
  final List<String> sampleInsertedCodes;
  final List<String> sampleUpdatedCodes;
  final List<String> sampleSkippedCodes;

  const ClientsBulkImportResult({
    required this.inserted,
    required this.updated,
    required this.skipped,
    required this.errors,
    required this.sampleErrors,
    required this.failureItems,
    required this.sampleInsertedCodes,
    required this.sampleUpdatedCodes,
    required this.sampleSkippedCodes,
  });
}

class ClientsBulkImportFailureItem {
  final String name;
  final String? code;
  final String message;

  const ClientsBulkImportFailureItem({
    required this.name,
    required this.code,
    required this.message,
  });
}

class ClientsDataSourceException implements Exception {
  const ClientsDataSourceException(this.message);

  final String message;

  @override
  String toString() => message;
}
