import 'package:equatable/equatable.dart';

class Client extends Equatable {
  const Client({
    required this.id,
    required this.name,
    required this.code,
    this.nationalityId,
  });

  factory Client.fromRmsLookupJson(Map<String, Object?> json) {
    final idValue = json['id'];
    final nameValue = json['name'];
    final codeValue = json['code'];
    final nationalityValue = json['nationalityId'];

    final id = switch (idValue) {
      int v => v,
      num v => v.toInt(),
      String v => int.tryParse(v.trim()),
      _ => null,
    };
    if (id == null) {
      throw Exception('Invalid RMS client id.');
    }
    if (nameValue is! String || nameValue.trim().isEmpty) {
      throw Exception('Invalid RMS client name.');
    }
    final code = codeValue is String && codeValue.trim().isNotEmpty
        ? codeValue.trim()
        : null;

    final nationalityId = switch (nationalityValue) {
      int v => v,
      num v => v.toInt(),
      String v => int.tryParse(v.trim()),
      _ => null,
    };

    return Client(
      id: id,
      name: nameValue.trim(),
      code: code,
      nationalityId: nationalityId,
    );
  }

  final int id;
  final String name;
  final String? code;
  final int? nationalityId;

  String get label {
    final normalizedCode = code?.trim();
    if (normalizedCode == null || normalizedCode.isEmpty) {
      return '$id - $name';
    }
    return '$normalizedCode - $name';
  }

  @override
  List<Object?> get props => <Object?>[id, name, code, nationalityId];
}
