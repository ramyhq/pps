import 'package:equatable/equatable.dart';

class RmsLookupItem extends Equatable {
  const RmsLookupItem({
    required this.key,
    required this.id,
    required this.code,
    required this.name,
    required this.label,
  });

  factory RmsLookupItem.fromJson(Map<String, Object?> json) {
    final keyValue = json['key'];
    final idValue = json['id'];
    final codeValue = json['code'];
    final nameValue = json['name'];
    final labelValue = json['label'];

    final id = switch (idValue) {
      int v => v,
      num v => v.toInt(),
      String v => int.tryParse(v.trim()),
      _ => null,
    };

    final key = switch (keyValue) {
      String v when v.trim().isNotEmpty => v.trim(),
      _ => id?.toString(),
    };
    if (key == null || key.trim().isEmpty) {
      throw Exception('Invalid RMS lookup key.');
    }

    final name = nameValue is String && nameValue.trim().isNotEmpty
        ? nameValue.trim()
        : null;
    final label = labelValue is String && labelValue.trim().isNotEmpty
        ? labelValue.trim()
        : name;
    if (label == null || label.trim().isEmpty) {
      throw Exception('Invalid RMS lookup label.');
    }

    final code =
        codeValue is String && codeValue.trim().isNotEmpty ? codeValue.trim() : null;

    return RmsLookupItem(
      key: key,
      id: id,
      code: code,
      name: name ?? label,
      label: label,
    );
  }

  final String key;
  final int? id;
  final String? code;
  final String name;
  final String label;

  Map<String, Object?> toJson() => <String, Object?>{
        'key': key,
        'id': id,
        'code': code,
        'name': name,
        'label': label,
      };

  @override
  List<Object?> get props => <Object?>[key, id, code, name, label];
}

