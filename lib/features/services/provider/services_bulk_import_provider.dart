import 'dart:convert';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pps/core/supabase/supabase_client_provider.dart';
import 'package:pps/features/services/data/data_sources/services_remote_data_source.dart';
import 'package:pps/features/services/data/models/service_type_import_row.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:universal_html/html.dart' as html;
import 'package:universal_io/io.dart' as io;

class ServicesBulkImportState {
  static const _unset = Object();

  final List<String> logs;
  final bool isUploading;
  final ServicesPendingImport? pendingImport;

  const ServicesBulkImportState({
    this.logs = const [],
    this.isUploading = false,
    this.pendingImport,
  });

  ServicesBulkImportState copyWith({
    List<String>? logs,
    bool? isUploading,
    Object? pendingImport = _unset,
  }) {
    return ServicesBulkImportState(
      logs: logs ?? this.logs,
      isUploading: isUploading ?? this.isUploading,
      pendingImport: pendingImport == _unset
          ? this.pendingImport
          : pendingImport as ServicesPendingImport?,
    );
  }
}

class ServicesPendingImport {
  final String fileName;
  final int totalRecords;
  final int validRecords;
  final int invalidRecords;
  final int duplicateKeysInFile;
  final int existingKeysInDb;
  final List<Map<String, dynamic>> rows;

  const ServicesPendingImport({
    required this.fileName,
    required this.totalRecords,
    required this.validRecords,
    required this.invalidRecords,
    required this.duplicateKeysInFile,
    required this.existingKeysInDb,
    required this.rows,
  });
}

final servicesRemoteDataSourceProvider = Provider<ServicesRemoteDataSource>((
  ref,
) {
  final supabaseClient = ref.watch(supabaseClientProvider);
  return ServicesRemoteDataSource(supabaseClient: supabaseClient);
});

final servicesBulkImportProvider =
    NotifierProvider.autoDispose<
      ServicesBulkImportNotifier,
      ServicesBulkImportState
    >(ServicesBulkImportNotifier.new);

class ServicesBulkImportNotifier extends Notifier<ServicesBulkImportState> {
  @override
  ServicesBulkImportState build() {
    return const ServicesBulkImportState(
      logs: ['[System] Ready to import Services...'],
    );
  }

  void _addLog(String message) {
    state = state.copyWith(logs: [...state.logs, message]);
  }

  Future<void> downloadTemplate() async {
    _addLog('[Process] Generating template for Services...');

    try {
      const csvContent = 'key,label,code\nairport_transfer,Airport Transfer,AT';
      final bytes = utf8.encode(csvContent);
      const fileName = 'services_template.csv';

      if (kIsWeb) {
        final blob = html.Blob([bytes]);
        final url = html.Url.createObjectUrlFromBlob(blob);
        html.AnchorElement(href: url)
          ..setAttribute('download', fileName)
          ..click();
        html.Url.revokeObjectUrl(url);
        _addLog('[Success] Template downloaded successfully.');
        return;
      }

      final outputFile = await FilePicker.saveFile(
        dialogTitle: 'Save Template',
        fileName: fileName,
        type: FileType.custom,
        allowedExtensions: ['csv'],
      );

      if (outputFile == null) {
        _addLog('[Warning] Template download canceled.');
        return;
      }

      await io.File(outputFile).writeAsBytes(bytes);
      _addLog('[Success] Template saved to $outputFile');
    } catch (e) {
      _addLog('[Error] Failed to download template: $e');
    }
  }

  Future<void> prepareUpload() async {
    state = state.copyWith(isUploading: true);
    try {
      _addLog('[System] Opening file picker...');
      final result = await FilePicker.pickFiles(
        type: FileType.any,
        withData: kIsWeb,
      );
      if (result == null) {
        _addLog('[Warning] User canceled file selection.');
        return;
      }

      final file = result.files.single;
      final fileName = file.name;
      final ext = _fileExtension(fileName);

      _addLog('[System] Selected file: $fileName');
      _addLog('[Process] Validating uploaded file...');

      if (ext == 'xlsx') {
        _addLog('[Error] XLSX is not supported yet. Please upload a CSV file.');
        return;
      }

      final content = utf8.decode(
        await _readPickedFileBytes(file),
        allowMalformed: true,
      );
      final records = _parseCsvRecords(content);
      if (records.isEmpty) {
        _addLog('[Error] The uploaded file is empty or invalid.');
        return;
      }

      final rows = <Map<String, dynamic>>[];
      var invalid = 0;
      for (final record in records) {
        try {
          final model = ServiceTypeImportRow.fromCsvRecord(record);
          rows.add(model.toJson());
        } catch (_) {
          invalid += 1;
        }
      }

      _addLog('[Process] Found ${rows.length} valid records.');
      if (invalid > 0) {
        _addLog(
          '[Warning] Skipped $invalid row(s) due to missing required fields.',
        );
      }

      final dataSource = ref.read(servicesRemoteDataSourceProvider);
      final keys = <String>{};
      var duplicateKeys = 0;
      for (final row in rows) {
        final keyValue = (row['key'] as String?)?.trim();
        if (keyValue == null || keyValue.isEmpty) continue;
        if (!keys.add(keyValue)) duplicateKeys += 1;
      }
      if (duplicateKeys > 0) {
        _addLog(
          '[Warning] Found $duplicateKeys duplicate key(s) inside the file. Duplicates will be skipped.',
        );
      }

      final existingKeys = await dataSource
          .findExistingReservationServiceTypeKeys(keys);
      final pending = ServicesPendingImport(
        fileName: fileName,
        totalRecords: records.length,
        validRecords: rows.length,
        invalidRecords: invalid,
        duplicateKeysInFile: duplicateKeys,
        existingKeysInDb: existingKeys.length,
        rows: rows,
      );
      state = state.copyWith(pendingImport: pending);
      _addLog(
        '[System] Ready to import: ${pending.validRecords} record(s). Existing keys in DB (visible to current user): ${pending.existingKeysInDb}.',
      );
    } on PostgrestException catch (e) {
      _addLog('[Error] Supabase error: ${e.message}');
    } catch (e) {
      _addLog('[Error] Upload failed: $e');
    } finally {
      state = state.copyWith(isUploading: false);
    }
  }

  void cancelPendingImport() {
    if (state.pendingImport == null) return;
    state = state.copyWith(pendingImport: null);
    _addLog('[System] Import canceled.');
  }

  Future<void> confirmImport() async {
    final pending = state.pendingImport;
    if (pending == null) return;

    state = state.copyWith(isUploading: true, pendingImport: null);
    try {
      _addLog('[System] Starting bulk import for Services...');
      _addLog('[Process] Importing records to database...');

      final dataSource = ref.read(servicesRemoteDataSourceProvider);
      final result = await dataSource.importReservationServiceTypes(
        pending.rows,
      );
      for (final keyValue in result.sampleInsertedKeys) {
        _addLog('[Inserted] key=$keyValue');
      }
      for (final keyValue in result.sampleUpdatedKeys) {
        _addLog('[Updated] key=$keyValue');
      }
      for (final keyValue in result.sampleSkippedKeys) {
        _addLog('[Skipped] key=$keyValue');
      }
      for (final message in result.sampleErrors) {
        if (message.startsWith('Duplicate key exists')) {
          _addLog('[Warning] $message');
        } else {
          _addLog('[Error] $message');
        }
      }

      final hasIdPkDuplicate = result.sampleErrors.any(
        (e) =>
            e.contains('reservation_service_types_pkey') ||
            e.contains('Key (id)=') ||
            e.contains('(id=') ||
            e.contains('Duplicate primary key'),
      );
      if (hasIdPkDuplicate) {
        _addLog(
          '[Warning] Database sequence for reservation_service_types.id may be out of sync. In Supabase SQL Editor run: select setval(pg_get_serial_sequence(\'public.reservation_service_types\', \'id\'), (select coalesce(max(id), 0) from public.reservation_service_types) + 1, false);',
        );
      }

      _addLog(
        '[Success] Completed. Inserted: ${result.inserted}, Updated: ${result.updated}, Skipped: ${result.skipped}, Errors: ${result.errors}.',
      );
    } on PostgrestException catch (e) {
      _addLog('[Error] Supabase error: ${e.message}');
    } catch (e) {
      _addLog('[Error] Upload failed: $e');
    } finally {
      state = state.copyWith(isUploading: false);
    }
  }

  String _fileExtension(String fileName) {
    final index = fileName.lastIndexOf('.');
    if (index <= 0 || index == fileName.length - 1) return '';
    return fileName.substring(index + 1).toLowerCase();
  }

  Future<Uint8List> _readPickedFileBytes(PlatformFile file) async {
    final inMemoryBytes = file.bytes;
    if (inMemoryBytes != null) {
      return Uint8List.fromList(inMemoryBytes);
    }

    if (kIsWeb) {
      throw StateError(
        'Missing bytes for web upload. Please pick file with data.',
      );
    }

    final path = file.path;
    if (path == null || path.isEmpty) {
      throw StateError('Selected file has no bytes and no path.');
    }

    return io.File(path).readAsBytes();
  }

  List<Map<String, String>> _parseCsvRecords(String input) {
    final rows = _parseCsvRows(input);
    if (rows.length < 2) return const [];

    final header = rows.first;
    final records = <Map<String, String>>[];

    for (var i = 1; i < rows.length; i++) {
      final values = rows[i];
      if (values.every((value) => value.trim().isEmpty)) continue;

      final record = <String, String>{};
      for (var j = 0; j < header.length; j++) {
        final key = header[j].trim();
        final value = j < values.length ? values[j] : '';
        if (key.isEmpty) continue;
        record[key] = value;
      }
      records.add(record);
    }

    return records;
  }

  List<List<String>> _parseCsvRows(String input) {
    final rows = <List<String>>[];
    final currentRow = <String>[];
    final currentField = StringBuffer();
    var inQuotes = false;

    for (var i = 0; i < input.length; i++) {
      final char = input[i];
      if (char == '"') {
        final nextIsQuote = i + 1 < input.length && input[i + 1] == '"';
        if (inQuotes && nextIsQuote) {
          currentField.write('"');
          i++;
        } else {
          inQuotes = !inQuotes;
        }
        continue;
      }

      if (char == ',' && !inQuotes) {
        currentRow.add(currentField.toString());
        currentField.clear();
        continue;
      }

      if ((char == '\n' || char == '\r') && !inQuotes) {
        if (char == '\r' && i + 1 < input.length && input[i + 1] == '\n') {
          i++;
        }
        currentRow.add(currentField.toString());
        currentField.clear();
        rows.add(List<String>.from(currentRow));
        currentRow.clear();
        continue;
      }

      currentField.write(char);
    }

    if (currentField.isNotEmpty || currentRow.isNotEmpty) {
      currentRow.add(currentField.toString());
      rows.add(List<String>.from(currentRow));
    }

    return rows;
  }
}
