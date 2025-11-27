import 'package:another_flushbar/flushbar.dart'; // <-- Import Flushbar
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zatch_app/controller/auth_controller/login_controller.dart';
import 'package:zatch_app/model/login_response.dart';
import 'package:zatch_app/view/category_screen/category_screen.dart';
import 'package:zatch_app/view/home_page.dart';
import '../../utils/auth_utils/base_screen.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'otp_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _obscurePassword = true;
  bool _isLoading = false;
  LoginResponse? _lastLoginResponse;
  String _selectedCountryCode = "91";

  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final LoginController _loginController = LoginController();

  // --- MODIFIED: Replaced SnackBar with Flushbar for showing messages ---
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

  // --- MODIFIED: Implemented detailed validation ---
  Future<void> _handleLogin() async {
    final phone = _phoneController.text.trim();
    final password = _passwordController.text.trim();

    // --- Granular Validation ---
    if (phone.isEmpty) {
      _showMessage("Validation Error", "Please enter your mobile number.");
      return;
    }
    if (phone.length != 10) {
      _showMessage("Validation Error", "Please enter a valid 10-digit mobile number.");
      return;
    }
    if (password.isEmpty) {
      _showMessage("Validation Error", "Please enter your password.");
      return;
    }

    setState(() => _isLoading = true);

    final countryCode = _selectedCountryCode;
    print("Login request -> phone: $phone, password: $password, countryCode: $countryCode");

    try {
      final res = await _loginController.loginUser(
        phone: phone,
        password: password,
        countryCode: countryCode,
      );
      _lastLoginResponse =res;
      print("Login response: $res");
      if (!mounted) return;

      final prefs = await SharedPreferences.getInstance();
      if (res.token.isNotEmpty) {
        await prefs.setString("authToken", res.token);
        print("Token saved in SharedPreferences: ${res.token}");
      }

      final savedCategories = prefs.getStringList("userCategories");
      print("Selected categories: $savedCategories");

      if (savedCategories == null || savedCategories.isEmpty) {
      print("Navigating to CategoryScreen");
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => CategoryScreen(
            title: "Let’s find you\nSomething to shop for.",
            loginResponse: res,
          ),
        ),
      );

      } else {
        print("Navigating to HomePage");
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => HomePage(loginResponse: res)),
        );
      }
    } catch (e) {
      print("Login error: $e");
      _lastLoginResponse = null;
      // Use the new message function for API or other errors
      _showMessage("Login Failed", e.toString(), isError: true);
    } finally {
      print("Login process finished");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleOtpLogin() async {
    setState(() => _isLoading = true);
    print("OTP login started");

    try {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return;

      final phone = _loginController.getRegisteredPhone() ?? "9019058876";
      final countryCode = _loginController.getRegisteredCountryCode() ?? "+91";

      print("OTP request -> phone: $phone, countryCode: $countryCode");

      if (_lastLoginResponse != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                OtpScreen(
                  phoneNumber: phone,
                  countryCode: countryCode,
                  loginResponse: _lastLoginResponse!,
                ),
          ),
        );
      }
    } catch (e) {
      print("OTP login error: $e");
      _showMessage("OTP Failed", e.toString(), isError: true);
    } finally {
      print("OTP login process finished");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final screenWidth = size.width;
    final screenHeight = size.height;

    final double inputHeight = screenHeight * 0.06;
    final double inputFontSize = screenWidth * 0.035;
    final double buttonFontSize = screenWidth * 0.045;
    final double spacingSmall = screenHeight * 0.02;
    final double spacingLarge = screenHeight * 0.04;
    final double paddingVertical = screenHeight * 0.018;

    return Stack(
      children: [
        BaseScreen(
          title: 'Login here',
          subtitle: 'Welcome back you’ve been missed!',
          contentWidgets: [
            SizedBox(height: spacingLarge),

            /// Phone + Country code
            Row(
              children: [
                Container(
                  height: inputHeight,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF2F4F5),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: CountryCodePicker(
                    initialSelection: 'IN',
                    favorite: const ['+91', 'IN'],
                    countryFilter: const ['IN'],
                    showDropDownButton: false,
                    onChanged: null, // Disabled
                    textStyle: TextStyle(
                      color: Colors.black54,
                      fontSize: inputFontSize,
                    ),
                    showFlag: false,
                    padding: EdgeInsets.zero,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Container(
                    height: inputHeight,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF2F4F5),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    // --- FIX: Align text to the left ---
                    alignment: Alignment.centerLeft,
                    child: TextField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(10),
                      ],
                      style: const TextStyle(color: Colors.black),
                      decoration: InputDecoration(
                        hintText: 'Mobile Number',
                        hintStyle: TextStyle(
                          color: Colors.black54,
                          fontSize: inputFontSize,
                        ),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: spacingSmall),

            /// Password
            Container(
              height: inputHeight,
              padding: const EdgeInsets.symmetric(horizontal: 18),
              decoration: BoxDecoration(
                color: const Color(0xFFF2F4F5),
                borderRadius: BorderRadius.circular(50),
              ),
              // --- FIX: Align text to the left ---
              alignment: Alignment.centerLeft,
              child: TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                style: const TextStyle(color: Colors.black),
                decoration: InputDecoration(
                  hintText: 'Password',
                  hintStyle: TextStyle(
                    color: Colors.black54,
                    fontSize: inputFontSize,
                  ),
                  border: InputBorder.none,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_off : Icons.visibility,
                      color: Colors.black54,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
              ),
            ),

            SizedBox(height: spacingLarge),

            /// Login button
            GestureDetector(
              onTap: _handleLogin,
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: paddingVertical),
                decoration: ShapeDecoration(
                  color: const Color(0xFFCCF656),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                ),
                child: Center(
                  child: Text(
                    'Login',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: buttonFontSize,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: spacingSmall),
            GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, '/register');
              },
              child: const Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: 'Dont have account? ',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 14,
                        fontFamily: 'Plus Jakarta Sans',
                        fontWeight: FontWeight.w400,
                        height: 1.64,
                      ),
                    ),
                    TextSpan(
                      text: 'Create Account',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 14,
                        fontFamily: 'Plus Jakarta Sans',
                        fontWeight: FontWeight.w700,
                        decoration: TextDecoration.underline,
                        height: 1.64,
                      ),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: spacingSmall),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Expanded(
                    child: Divider(thickness: 1, color: Colors.black26),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Text(
                      'Or',
                      style: TextStyle(
                        color: Colors.black.withOpacity(0.6),
                        fontWeight: FontWeight.w600,
                        fontSize: inputFontSize,
                      ),
                    ),
                  ),
                  const Expanded(
                    child: Divider(thickness: 1, color: Colors.black26),
                  ),
                ],
              ),
            ),
            SizedBox(height: spacingSmall),

            /// OTP login
            GestureDetector(
              onTap: _handleOtpLogin,
              child: Container(
                width: double.infinity,
                height: inputHeight,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.green),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Text(
                  'Sign in with OTP',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: inputFontSize + 2,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
          bottomText: Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: 'By continuing you are accepting all\n ',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: inputFontSize,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const TextSpan(
                  text: 'Terms & Conditions',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 14, // Made consistent
                    fontWeight: FontWeight.w700,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ],
            ),
            textAlign: TextAlign.center,
          ),
        ),

        /// Full screen loader overlay
        if (_isLoading)
          Container(
            color: Colors.black.withOpacity(0.5),
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
