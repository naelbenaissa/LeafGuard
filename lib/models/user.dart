class User {
  final String userId;
  final String email;
  final String firstName;
  final String lastName;
  final DateTime birthdate;
  final String phoneNumber;
  final DateTime createdAt;
  final String username;
  final String profileImage;

  /// Constructeur immuable pour l'objet User
  const User(
      this.userId,
      this.email,
      this.firstName,
      this.lastName,
      this.birthdate,
      this.phoneNumber,
      this.createdAt,
      this.username,
      this.profileImage,
      );

  /// Crée une instance de `User` à partir d’un JSON
  /// Assure le parsing des dates au format ISO8601
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      json['user_id'] as String,
      json['email'] as String,
      json['first_name'] as String,
      json['last_name'] as String,
      DateTime.parse(json['birthdate']),
      json['phone_number'] as String,
      DateTime.parse(json['created_at']),
      json['username'] as String,
      json['profile_image'] as String,
    );
  }
}
