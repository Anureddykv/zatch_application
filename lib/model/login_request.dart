class LoginRequest {
  final String phone;
  final String password;
  final String countryCode;

  LoginRequest({
    required this.phone,
    required this.password,
    required this.countryCode,

  });

  Map<String, dynamic> toJson() {
    return {
      "phone": phone,
      "password": password,
      "countryCode": countryCode,

    };
  }
}
