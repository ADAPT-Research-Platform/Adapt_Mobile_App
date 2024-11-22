
class User {
  final String userId;
  int? userCode;
  final String displayName;
  final String email;
  final DateTime createdDate;
  final String? role;

  User({
    required this.userId,
    this.userCode,
    required this.displayName,
    required this.email,
    required this.createdDate,
    this.role
  });
}
