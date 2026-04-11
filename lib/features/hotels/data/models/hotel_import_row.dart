class HotelImportRow {
  final String? code;
  final String name;
  final String? city;
  final String? category;
  final int? supplierId;

  const HotelImportRow({
    required this.name,
    this.code,
    this.city,
    this.category,
    this.supplierId,
  });

  factory HotelImportRow.fromCsvRecord(Map<String, String> record) {
    final normalized = record.map((key, value) {
      return MapEntry(_normalizeHeader(key), value.trim());
    });

    final name = _firstNonEmpty(normalized, ['name', 'hotelname']);
    if (name == null || name.isEmpty) {
      throw const HotelImportException('Missing required field: name');
    }

    final code = _firstNonEmpty(normalized, ['code', 'hotelcode']);
    final city = _firstNonEmpty(normalized, ['city', 'location']);
    final category = _firstNonEmpty(normalized, ['category', 'stars']);
    final supplierIdRaw = _firstNonEmpty(normalized, ['supplier_id', 'supplierid']);
    final supplierId = int.tryParse(supplierIdRaw ?? '');

    return HotelImportRow(
      name: name,
      code: (code?.isEmpty ?? true) ? null : code,
      city: (city?.isEmpty ?? true) ? null : city,
      category: (category?.isEmpty ?? true) ? null : category,
      supplierId: supplierId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      if (code != null) 'code': code,
      if (city != null) 'city': city,
      if (category != null) 'category': category,
      if (supplierId != null) 'supplier_id': supplierId,
    };
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

class HotelImportException implements Exception {
  const HotelImportException(this.message);

  final String message;

  @override
  String toString() => message;
}
