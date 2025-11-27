import 'package:flutter/foundation.dart';
import 'package:zatch_app/model/otp_req.dart';
import 'package:zatch_app/model/otp_response_model.dart';
import 'package:zatch_app/model/verify_otp_request.dart';
import 'package:zatch_app/model/verify_otp_response.dart';
import 'package:zatch_app/services/api_service.dart';

class OtpController {
  final ApiService _apiService = ApiService();

  Future<ResponseApi?> sendOtp(String phoneNumber, String countryCode) async {
    try {
      final req = SendOtpRequest(
        countryCode: countryCode,
        phoneNumber: phoneNumber,
      );
      debugPrint(" Sending OTP Request: ${req.toJson()}");

      final res = await _apiService.sendOtp(req);
      debugPrint(" Send OTP Response: ${res.toJson()}");
      return res;
    } catch (e) {
      debugPrint(" Send OTP Error: $e");
      return null;
    }
  }

  Future<VerifyApiResponse?> verifyOtp(String phoneNumber, String countryCode, String otp) async {
    try {
      final req = VerifyOtpRequest(
        countryCode: countryCode,
        phoneNumber: phoneNumber,
        otp: otp,
      );
      debugPrint(" Verify OTP Request: ${req.toJson()}");

      // This now returns VerifyApiResponse
      final res = await _apiService.verifyOtp(req);
      debugPrint(" Verify OTP Response: ${res.toJson()}");
      return res;
    } catch (e) {
      debugPrint(" Verify OTP Error: $e");
      return null;
    }
  }
}
