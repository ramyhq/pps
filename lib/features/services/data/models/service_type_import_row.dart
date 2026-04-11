class ServiceTypeImportRow {
  final String keyValue;
  final String? label;
  final String? code;

  const ServiceTypeImportRow({required this.keyValue, this.label, this.code});

  factory ServiceTypeImportRow.fromCsvRecord(Map<String, String> record) {
    final normalized = record.map((key, value) {
      return MapEntry(_normalizeHeader(key), value.trim());
    });

    final key = _firstNonEmpty(normalized, ['key']) ??
        _slugify(_firstNonEmpty(normalized, ['code']) ?? '') ??
        _slugify(_firstNonEmpty(normalized, ['label', 'name']) ?? '');

    if (key == null || key.isEmpty) {
      throw const ServiceTypeImportException('Missing required field: key');
    }

    final label = _firstNonEmpty(normalized, ['label', 'name']);
    final code = _firstNonEmpty(normalized, ['code']);

    return ServiceTypeImportRow(
      keyValue: key,
      label: (label?.isEmpty ?? true) ? null : label,
      code: (code?.isEmpty ?? true) ? null : code,
    );
  }

  Map<String, dynamic> toJson() {
    return {'key': keyValue, if (label != null) 'label': label, if (code != null) 'code': code};
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

  static String? _slugify(String input) {
    final trimmed = input.trim().toLowerCase();
    if (trimmed.isEmpty) return null;
    final buffer = StringBuffer();
    var lastWasUnderscore = false;
    for (final unit in trimmed.codeUnits) {
      final c = String.fromCharCode(unit);
      final isAllowed = RegExp(r'[a-z0-9]').hasMatch(c);
      if (isAllowed) {
        buffer.write(c);
        lastWasUnderscore = false;
        continue;
      }
      if (!lastWasUnderscore) {
        buffer.write('_');
        lastWasUnderscore = true;
      }
    }
    final slug = buffer.toString().replaceAll(RegExp(r'^_+|_+$'), '');
    return slug.isEmpty ? null : slug;
  }
}

class ServiceTypeImportException implements Exception {
  const ServiceTypeImportException(this.message);

  final String message;

  @override
  String toString() => message;
}
