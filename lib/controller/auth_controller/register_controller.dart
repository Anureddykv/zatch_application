import 'package:flutter/material.dart';
import 'package:zatch_app/model/register_req.dart';
import 'package:zatch_app/model/register_response_model.dart';
import 'package:zatch_app/services/api_service.dart';
import 'package:zatch_app/view/auth_view/OtpScreenRegister.dart';

class RegisterController {
  final api = ApiService();

  Future<void> registerUser({
    required BuildContext context,
    required String username,
    required String password,
    required String countryCode,
    required String phone,
    required String gender,
    required String email,
    required Function(String title, String message, {bool isError}) showMessage,
  }) async {
    try {
      final request = RegisterRequest(
        username: username,
        password: password,
        countryCode: countryCode,
        phone: phone,
        gender: gender,
        email: email,
      );
      final RegisterResponse result = await api.registerUser(request);
      if (!Navigator.of(context).mounted) return;

      if (result.success) {
        debugPrint("Registration Success: ${result.message}");
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OtpScreenRegister(
              phoneNumber: result.user.phone,
              countryCode: result.user.countryCode,
            ),
          ),
        );
      } else {
        debugPrint("Registration Failed: ${result.message}");
        showMessage("Registration Failed", result.message, isError: true);
      }
    } catch (e) {
      debugPrint(" Register Exception: $e");
      showMessage("An Error Occurred", "Something went wrong. Please try again.", isError: true);
    }
  }
}
