class ClientImportRow {
  final String? code;
  final String name;

  const ClientImportRow({required this.name, this.code});

  factory ClientImportRow.fromCsvRecord(Map<String, String> record) {
    final normalized = record.map((key, value) {
      return MapEntry(_normalizeHeader(key), value.trim());
    });

    final name = _firstNonEmpty(normalized, ['name', 'clientname']);
    if (name == null || name.isEmpty) {
      throw const ClientImportException('Missing required field: name');
    }

    final code = _firstNonEmpty(normalized, ['code', 'clientcode']);
    return ClientImportRow(
      name: name,
      code: (code?.isEmpty ?? true) ? null : code,
    );
  }

  Map<String, dynamic> toJson() {
    return {'name': name, if (code != null) 'code': code};
  }

  static String _normalizeHeader(String input) {
    final lower = input.trim().toLowerCase();
    final buffer = StringBuffer();
    for (final unit in lower.codeUnits) {
      final c = String.fromCharCode(unit);
      if (RegExp(r'[a-z0-9_]').hasMatch(c)) {
        buffer.write(c);
      } else if (c == ' ' || c == '-' || c == '.') {
        buffer.write('_');
      }
    }
    return buffer.toString().replaceAll('__', '_');
  }

  static String? _firstNonEmpty(Map<String, String> record, List<String> keys) {
    for (final key in keys) {
      final value = record[key];
      if (value != null && value.trim().isNotEmpty) return value.trim();
    }
    return null;
  }
}

class ClientImportException implements Exception {
  const ClientImportException(this.message);

  final String message;

  @override
  String toString() => message;
}
