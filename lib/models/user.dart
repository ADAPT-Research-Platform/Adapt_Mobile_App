class User {
  final String userId;
  final String userName;
  final String email;

  User({
    required this.userId,
    required this.userName,
    required this.email,
  });

  // Create a User object from a JSON map
  factory User.parse(Map<String, dynamic> json) {
    return User(
      userId: json['userId'],
      userName: json['userName'],
      email: json['email'],
    );
  }

  // Convert a User object to a JSON map
  Map<String, String> toJson() {
    return {
      'userId': userId,
      'userName': userName,
      'email': email,
    };
  }
}
