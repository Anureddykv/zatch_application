import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:zatch_app/controller/auth_controller/otp_controller.dart';
import 'package:zatch_app/model/verify_otp_response.dart';
import 'package:zatch_app/view/auth_view/login.dart';
import '../../utils/auth_utils/base_screen.dart';

class OtpScreenRegister extends StatefulWidget {
  final String phoneNumber;
  final String countryCode;

  const OtpScreenRegister({
    super.key,
    required this.phoneNumber,
    required this.countryCode,
  });

  @override
  State<OtpScreenRegister> createState() => _OtpScreenRegisterState();
}

class _OtpScreenRegisterState extends State<OtpScreenRegister> {
  final List<TextEditingController> _controllers =
  List.generate(4, (index) => TextEditingController());
  final List<FocusNode> _focusNodes =
  List.generate(4, (index) => FocusNode());

  final OtpController _otpController = OtpController();

  bool _isLoading = false;
  int _resendTimer = 0;
  bool _canResend = true;

  @override
  void initState() {
    super.initState();
    _sendOtpOnStart();
  }

  @override
  void dispose() {
    for (var c in _controllers) c.dispose();
    for (var f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  /// Custom message handler using Flushbar
  void _showMessage(String title, String message, {bool isError = true}) {
    if (!mounted) return;
    Flushbar(
      title: title,
      message: message,
      duration: const Duration(seconds: 3),
      backgroundColor: isError ? Colors.red : Colors.green,
      margin: const EdgeInsets.all(8),
      borderRadius: BorderRadius.circular(8),
      icon: Icon(
        isError ? Icons.error_outline : Icons.check_circle_outline,
        size: 28.0,
        color: Colors.white,
      ),
      flushbarPosition: FlushbarPosition.TOP,
    ).show(context);
  }

  /// Auto-send OTP on screen load
  Future<void> _sendOtpOnStart() async {
    setState(() => _isLoading = true);
    final apiResponse =
    await _otpController.sendOtp(/*widget.phoneNumber*/ "9019058876", widget.countryCode);
    if (!mounted) return;

    setState(() => _isLoading = false);
    if (apiResponse != null && apiResponse.success) {
      _showMessage("Success", "OTP sent to ${apiResponse.data.to}",
          isError: false);
      _startResendTimer();
    } else {
      _showMessage("Error", apiResponse?.message ?? "Failed to send OTP");
    }
  }
  /// Clears all OTP input fields.
  void _clearOtpFields() {
    for (var controller in _controllers) {
      controller.clear();
    }
    // Optionally, move focus back to the first box
    if (_focusNodes.isNotEmpty) {
      _focusNodes[0].requestFocus();
    }
  }

  /// Resend OTP
  Future<void> _resendOtp() async {
    if (!_canResend) return;
    _clearOtpFields();
    setState(() {
      _isLoading = true;
      _canResend = false;
    });

    final apiResponse =
    await _otpController.sendOtp(/*widget.phoneNumber*/ "9019058876", widget.countryCode);
    if (!mounted) return;

    setState(() => _isLoading = false);
    if (apiResponse != null && apiResponse.success) {
      _showMessage("Success", "OTP resent to ${apiResponse.data.to}",
          isError: false);
      _startResendTimer();
    } else {
      _showMessage("Error", apiResponse?.message ?? "Failed to resend OTP");
    }
  }

  /// Verify OTP on Register button
  Future<void> _verifyOtp() async {
    final otp = _controllers.map((c) => c.text).join();
    if (otp.length != 4) {
      _showMessage("Invalid OTP", "Please enter the complete 4-digit OTP");
      return;
    }

    setState(() => _isLoading = true);
    final VerifyApiResponse? res = await _otpController.verifyOtp(
        /*widget.phoneNumber*/"9019058876", widget.countryCode, otp);

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (res != null && res.data.valid == true) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
            (route) => false,
      );
      _showMessage("Success", "✅ OTP Verified Successfully", isError: false);
    } else {
      _showMessage("Verification Failed",
          res?.message ?? "The OTP is incorrect or has expired.");
    }
  }

  void _startResendTimer() {
    setState(() {
      _resendTimer = 30;
      _canResend = false;
    });

    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return false;
      if (_resendTimer > 1) {
        setState(() => _resendTimer--);
        return true;
      } else {
        setState(() {
          _resendTimer = 0;
          _canResend = true;
        });
        return false;
      }
    });
  }

  void _onOtpChanged(String value, int index) {
    if (value.length == 1 && index < 3) {
      _focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        BaseScreen(
          title: 'Register',
          subtitle: 'Welcome to Zatch!!',
          contentWidgets: [
            const SizedBox(height: 20),
            const Text("OTP Verification",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            const Text(
              "Enter the 4-digit OTP received on your \nmobile number",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.black87),
            ),
            const SizedBox(height: 24),

            /// OTP input boxes
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(4, (index) {
                return Container(
                  width: 55,
                  height: 55,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: _focusNodes[index].hasFocus
                          ? const Color(0xFFCCF656)
                          : Colors.grey.shade400,
                      width: 2,
                    ),
                  ),
                  child: TextField(
                    controller: _controllers[index],
                    focusNode: _focusNodes[index],
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.bold),
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(1),
                    ],
                    onChanged: (value) => _onOtpChanged(value, index),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      counterText: "",
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 20),

            /// Resend
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Didn't receive OTP ? "),
                GestureDetector(
                  onTap: _canResend ? _resendOtp : null,
                  child: Text(
                    _canResend ? "Resend" : "Resend in $_resendTimer sec",
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w600,
                      decoration: _canResend
                          ? TextDecoration.underline
                          : TextDecoration.none,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),
          ],
          bottomText: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: double.infinity,
                height: 50,
                margin: const EdgeInsets.symmetric(vertical: 6),
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                    side: const BorderSide(color: Colors.green),
                  ),
                  child: const Text("Back",
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black)),
                ),
              ),
              Container(
                width: double.infinity,
                height: 50,
                margin: const EdgeInsets.symmetric(vertical: 6),
                child: ElevatedButton(
                  onPressed: _verifyOtp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFCCF656),
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                  ),
                  child: const Text("Register",
                      style:
                      TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        ),

        /// Center Loader Overlay
        if (_isLoading)
          Container(
            color: Colors.black45,
            child: const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(Colors.white),
              ),
            ),
          ),
      ],
    );
  }
}
