class RmsUserInfo {
  const RmsUserInfo({
    required this.userName,
    required this.fullName,
    required this.emailAddress,
    required this.id,
  });

  final String userName;
  final String fullName;
  final String? emailAddress;
  final int? id;
}
