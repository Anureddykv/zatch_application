class VerifyOtpRequest {
  final String countryCode;
  final String phoneNumber;
  final String otp;

  VerifyOtpRequest({
    required this.countryCode,
    required this.phoneNumber,
    required this.otp,
  });

  Map<String, dynamic> toJson() {
    return {
      "countryCode": countryCode,
      "phoneNumber": phoneNumber,
      "otp": otp,
    };
  }
}
