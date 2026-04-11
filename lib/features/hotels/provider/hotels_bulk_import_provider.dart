import 'dart:convert';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pps/core/supabase/supabase_client_provider.dart';
import 'package:pps/features/hotels/data/data_sources/hotels_remote_data_source.dart';
import 'package:pps/features/hotels/data/models/hotel_import_row.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:universal_html/html.dart' as html;
import 'package:universal_io/io.dart' as io;

class HotelsBulkImportState {
  static const _unset = Object();

  final List<String> logs;
  final bool isUploading;
  final HotelsPendingImport? pendingImport;

  const HotelsBulkImportState({
    this.logs = const [],
    this.isUploading = false,
    this.pendingImport,
  });

  HotelsBulkImportState copyWith({
    List<String>? logs,
    bool? isUploading,
    Object? pendingImport = _unset,
  }) {
    return HotelsBulkImportState(
      logs: logs ?? this.logs,
      isUploading: isUploading ?? this.isUploading,
      pendingImport: pendingImport == _unset
          ? this.pendingImport
          : pendingImport as HotelsPendingImport?,
    );
  }
}

class HotelsPendingImport {
  final String fileName;
  final int totalRecords;
  final int validRecords;
  final int invalidRecords;
  final int duplicateCodesInFile;
  final int existingCodesInDb;
  final List<Map<String, dynamic>> rows;

  const HotelsPendingImport({
    required this.fileName,
    required this.totalRecords,
    required this.validRecords,
    required this.invalidRecords,
    required this.duplicateCodesInFile,
    required this.existingCodesInDb,
    required this.rows,
  });
}

final hotelsRemoteDataSourceProvider = Provider<HotelsRemoteDataSource>((ref) {
  final supabaseClient = ref.watch(supabaseClientProvider);
  return HotelsRemoteDataSource(supabaseClient: supabaseClient);
});

final hotelsBulkImportProvider =
    NotifierProvider.autoDispose<
      HotelsBulkImportNotifier,
      HotelsBulkImportState
    >(HotelsBulkImportNotifier.new);

class HotelsBulkImportNotifier extends Notifier<HotelsBulkImportState> {
  @override
  HotelsBulkImportState build() {
    return const HotelsBulkImportState(
      logs: ['[System] Ready to import Hotels...'],
    );
  }

  void _addLog(String message) {
    state = state.copyWith(logs: [...state.logs, message]);
  }

  Future<void> downloadTemplate() async {
    _addLog('[Process] Generating template for Hotels...');

    try {
      const csvContent =
          'code,name,city,category,supplier_id\nH-0001,Grand Hotel,Dubai,5,';
      final bytes = utf8.encode(csvContent);
      const fileName = 'hotels_template.csv';

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
          final model = HotelImportRow.fromCsvRecord(record);
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

      final dataSource = ref.read(hotelsRemoteDataSourceProvider);
      final codes = <String>{};
      var duplicateCodes = 0;
      for (final row in rows) {
        final code = (row['code'] as String?)?.trim();
        if (code == null || code.isEmpty) continue;
        if (!codes.add(code)) duplicateCodes += 1;
      }
      if (duplicateCodes > 0) {
        _addLog(
          '[Warning] Found $duplicateCodes duplicate code(s) inside the file. Duplicates will be skipped.',
        );
      }

      final existingCodes = await dataSource.findExistingHotelCodes(codes);
      final pending = HotelsPendingImport(
        fileName: fileName,
        totalRecords: records.length,
        validRecords: rows.length,
        invalidRecords: invalid,
        duplicateCodesInFile: duplicateCodes,
        existingCodesInDb: existingCodes.length,
        rows: rows,
      );
      state = state.copyWith(pendingImport: pending);
      _addLog(
        '[System] Ready to import: ${pending.validRecords} record(s). Existing codes in DB (visible to current user): ${pending.existingCodesInDb}.',
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
      _addLog('[System] Starting bulk import for Hotels...');
      _addLog('[Process] Importing records to database...');

      final dataSource = ref.read(hotelsRemoteDataSourceProvider);
      final result = await dataSource.importHotels(pending.rows);
      for (final code in result.sampleInsertedCodes) {
        _addLog('[Inserted] code=$code');
      }
      for (final code in result.sampleUpdatedCodes) {
        _addLog('[Updated] code=$code');
      }
      for (final code in result.sampleSkippedCodes) {
        _addLog('[Skipped] code=$code');
      }
      for (final message in result.sampleErrors) {
        if (message.startsWith('Duplicate code exists')) {
          _addLog('[Warning] $message');
        } else {
          _addLog('[Error] $message');
        }
      }

      final hasIdPkDuplicate = result.sampleErrors.any(
        (e) =>
            e.contains('hotels_pkey') ||
            e.contains('Key (id)=') ||
            e.contains('(id=') ||
            e.contains('Duplicate primary key'),
      );
      if (hasIdPkDuplicate) {
        _addLog(
          '[Warning] Database sequence for hotels.id may be out of sync. In Supabase SQL Editor run: select setval(pg_get_serial_sequence(\'public.hotels\', \'id\'), (select coalesce(max(id), 0) from public.hotels) + 1, false);',
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
