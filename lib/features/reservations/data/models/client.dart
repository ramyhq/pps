import 'package:equatable/equatable.dart';

class Client extends Equatable {
  const Client({
    required this.id,
    required this.name,
    required this.code,
  });

  final int id;
  final String name;
  final String? code;

  String get label {
    final normalizedCode = code?.trim();
    if (normalizedCode == null || normalizedCode.isEmpty) {
      return '$id - $name';
    }
    return '$normalizedCode - $name';
  }

  @override
  List<Object?> get props => <Object?>[id, name, code];
}

