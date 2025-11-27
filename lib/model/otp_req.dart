class SendOtpRequest {
  final String countryCode;
  final String phoneNumber;

  SendOtpRequest({
    required this.countryCode,
    required this.phoneNumber,
  });

  Map<String, dynamic> toJson() {
    return {
      "countryCode": countryCode,
      "phoneNumber": phoneNumber,
    };
  }
}
