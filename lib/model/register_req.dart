class RegisterRequest {
  final String username;
  final String password;
  final String countryCode;
  final String phone;
  final String gender;
  final String email;

  RegisterRequest({
    required this.username,
    required this.password,
    required this.countryCode,
    required this.phone,
    required this.gender,
    required this.email,
  });

  Map<String, dynamic> toJson() {
    return {
      "username": username,
      "password": password,
      "countryCode": countryCode,
      "phone": phone,
      "gender": gender,
      "email": email,
    };
  }
}
