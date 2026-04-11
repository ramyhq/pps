import 'package:equatable/equatable.dart';

class Hotel extends Equatable {
  const Hotel({
    required this.id,
    required this.name,
    required this.code,
    required this.city,
  });

  factory Hotel.fromRmsLookupJson(Map<String, Object?> json) {
    final idValue = json['id'];
    final nameValue = json['name'];
    final codeValue = json['code'];
    final cityValue = json['city'];

    final id = switch (idValue) {
      int v => v,
      num v => v.toInt(),
      String v => int.tryParse(v.trim()),
      _ => null,
    };
    if (id == null) {
      throw Exception('Invalid RMS hotel id.');
    }
    if (nameValue is! String || nameValue.trim().isEmpty) {
      throw Exception('Invalid RMS hotel name.');
    }
    final code = codeValue is String && codeValue.trim().isNotEmpty
        ? codeValue.trim()
        : null;
    final city = cityValue is String && cityValue.trim().isNotEmpty
        ? cityValue.trim()
        : null;

    return Hotel(id: id, name: nameValue.trim(), code: code, city: city);
  }

  final int id;
  final String name;
  final String? code;
  final String? city;

  String get label {
    final normalizedCode = code?.trim();
    if (normalizedCode == null || normalizedCode.isEmpty) {
      return '$id - $name';
    }
    return '$normalizedCode - $name';
  }

  @override
  List<Object?> get props => <Object?>[id, name, code, city];
}
