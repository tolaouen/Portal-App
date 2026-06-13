class RegisterRequest {
  const RegisterRequest({
    required this.username,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.password,
    required this.verifyPassword,
    this.dateOfBirth,
    this.gender,
    this.phone,
    this.roleId,
  });

  final String username;
  final String email;
  final String firstName;
  final String lastName;
  final String password;
  final String verifyPassword;
  final DateTime? dateOfBirth;
  final String? gender;
  final String? phone;
  final int? roleId;

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'date_of_birth': dateOfBirth?.toIso8601String(),
      'gender': gender,
      'phone': phone,
      'password': password,
      'verify_password': verifyPassword,
      'role_id': roleId,
    };
  }
}
