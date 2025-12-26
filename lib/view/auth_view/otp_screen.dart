import 'package:another_flushbar/flushbar.dart'; // Using Flushbar for better UX
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:zatch/controller/auth_controller/otp_controller.dart';
import 'package:zatch/model/login_response.dart';
import 'package:zatch/model/otp_response_model.dart';
import 'package:zatch/model/verify_otp_response.dart';
import 'package:zatch/utils/local_storage.dart';
import 'package:zatch/view/category_screen/category_screen.dart';
import 'package:zatch/view/home_page.dart';
import '../../utils/auth_utils/base_screen.dart';

class OtpScreen extends StatefulWidget {
  final String phoneNumber;
  final String countryCode;
  final LoginResponse loginResponse;

  const OtpScreen({
    super.key,
    required this.phoneNumber,
    required this.countryCode,
    required  this.loginResponse,
  });

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final List<TextEditingController> _controllers =
  List.generate(4, (index) => TextEditingController());
  final List<FocusNode> _focusNodes =
  List.generate(4, (index) => FocusNode());

  final OtpController _otpController = OtpController();

  bool _isLoading = false;
  int _resendTimer = 30; // Initialize with the timer duration
  bool _canResend = false; // Initially false until the first timer runs out

  @override
  void initState() {
    super.initState();
    _sendOtpOnStart();
  }

  @override
  void dispose() {
    for (var c in _controllers) c.dispose();
    for (var f in _focusNodes) f.dispose();
    super.dispose();
  }

  /// Custom message handler using Flushbar for consistent UI feedback
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
    // The controller returns ApiResponse?, so we handle that type
    final ResponseApi? apiResponse =
    await _otpController.sendOtp(widget.phoneNumber, widget.countryCode);

    if (!mounted) return;
    setState(() => _isLoading = false);

    // Check the response from the ApiResponse object
    if (apiResponse != null && apiResponse.success) {
      _showMessage("Success", "OTP sent to ${apiResponse.data.to}", isError: false);
      _startResendTimer(); // Start timer only on success
    } else {
      _showMessage("Error", apiResponse?.message ?? "Failed to send OTP");
    }
  }
  void _clearOtpFields() {
    for (var controller in _controllers) {
      controller.clear();
    }
    // Move focus back to the first OTP box for a better UX
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
      _canResend = false; // Disable button immediately
    });

    final ResponseApi? apiResponse =
    await _otpController.sendOtp(widget.phoneNumber, widget.countryCode);

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (apiResponse != null && apiResponse.success) {
      _showMessage("Success", "OTP resent to ${apiResponse.data.to}", isError: false);
      _startResendTimer(); // Restart timer
    } else {
      _showMessage("Error", apiResponse?.message ?? "Failed to resend OTP");
      setState(() => _canResend = true); // Re-enable if it fails
    }
  }
  /// Verify OTP
  Future<void> _verifyOtp() async {
    final otp = _controllers.map((c) => c.text).join();
    if (otp.length != 4) {
      // Use your consistent message handler
      _showMessage("Invalid Input", "Please enter the complete 4-digit OTP");
      return;
    }

    setState(() => _isLoading = true);
    final VerifyApiResponse? res =
    await _otpController.verifyOtp(widget.phoneNumber, widget.countryCode, otp);

    if (!mounted) return;
    setState(() => _isLoading = false);
    if (res != null && res.data.valid == true) {
      _showMessage("Success", "✅ OTP Verified Successfully", isError: false);

      final hasCategorySelected = await LocalStorage.hasSelectedCategory();
      if (!mounted) return;
      if (hasCategorySelected) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => HomePage(loginResponse: widget.loginResponse)),
        );
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CategoryScreen(
              title: "Let’s find you\nSomething to shop for.",
              loginResponse:widget.loginResponse,
            ),
          ),
        );
      }
    } else {
      _showMessage(
          "Verification Failed",
          res?.message ?? "The OTP is incorrect or has expired. Please try again."
      );
    }
  }


  /// Timer to control the resend button
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
        return true; // Continue looping
      } else {
        setState(() {
          _resendTimer = 0;
          _canResend = true;
        });
        return false; // Stop looping
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
          title: 'Login here',
          subtitle: 'Welcome back you’ve been missed!',
          contentWidgets: [
            const SizedBox(height: 20),
            const Text(
              "OTP Verification",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              "Enter the 4-digit OTP sent to ${widget.countryCode}${widget.phoneNumber}",
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),
            const SizedBox(height: 24),

            /// OTP input
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
                  child: const Text("Login",
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        ),

        /// ✅ Full-screen loader
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
