import 'package:another_flushbar/flushbar.dart'; // <-- Import Flushbar
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:zatch/controller/auth_controller/register_controller.dart';
import 'package:zatch/view/policy_screen.dart';
import '../../utils/auth_utils/base_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final RegisterController _controller = RegisterController();
  String _selectedGender = "";
  String _countryCode = "+91";
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

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

  Widget _genderChip(String label) {
    final bool isSelected = _selectedGender == label;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedGender = label),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFCCF656) : const Color(0xFFF2F4F5),
            borderRadius: BorderRadius.circular(50),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.black : const Color(0xFF121111),
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // --- MODIFIED: Implemented detailed validation ---
  Future<void> _register() async {
    if (_isLoading) return;

    // --- Granular Validation ---
    if (nameController.text.trim().isEmpty) {
      _showMessage("Validation Error", "Please enter your username.");
      return;
    }
    if (_selectedGender.isEmpty) {
      _showMessage("Validation Error", "Please select your gender.");
      return;
    }
    if (_emailController.text.trim().isEmpty) {
      _showMessage("Validation Error", "Please enter your email address.");
      return;
    }
    // Simple regex for email validation
    final emailRegExp = RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
    if (!emailRegExp.hasMatch(_emailController.text.trim())) {
      _showMessage("Validation Error", "Please enter a valid email address.");
      return;
    }
    if (_phoneController.text.trim().length != 10) {
      _showMessage("Validation Error", "Please enter a valid 10-digit mobile number.");
      return;
    }
    if (_passwordController.text.trim().isEmpty) {
      _showMessage("Validation Error", "Please enter a password.");
      return;
    }
    if (_passwordController.text.trim().length < 6) {
      _showMessage("Validation Error", "Password must be at least 6 characters long.");
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _controller.registerUser(
        context: context,
        username: nameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        countryCode: _countryCode,
        password: _passwordController.text.trim(),
        gender: _selectedGender,
        showMessage: _showMessage,
      );
    } catch (e) {
      _showMessage("Registration Failed", e.toString(), isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final screenWidth = size.width;
    final screenHeight = size.height;

    final inputHeight = screenHeight * 0.065;
    final inputFontSize = screenWidth * 0.035;
    final buttonFontSize = screenWidth * 0.045;
    final spacingSmall = screenHeight * 0.02;
    final spacingLarge = screenHeight * 0.04;
    final paddingVertical = screenHeight * 0.018;

    return Stack(
      children: [
        BaseScreen(
          title: 'Register',
          subtitle: 'Welcome to Zatch!!',
          contentWidgets: [
            SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  SizedBox(height: spacingLarge),

                  // Username
                  Container(
                    height: inputHeight,
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    alignment: Alignment.centerLeft,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF2F4F5),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        hintText: 'Username',
                        hintStyle: TextStyle(color: const Color(0xFF616161), fontSize: inputFontSize),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  SizedBox(height: spacingSmall),

                  // Gender
                  Row(
                    children: [
                      _genderChip("Male"),
                      _genderChip("Female"),
                      _genderChip("Other"),
                    ],
                  ),
                  SizedBox(height: spacingSmall),

                  // Email
                  Container(
                    height: inputHeight,
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    alignment: Alignment.centerLeft,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF2F4F5),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        hintText: 'Email ID',
                        hintStyle: TextStyle(color: const Color(0xFF616161), fontSize: inputFontSize),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  SizedBox(height: spacingSmall),

                  // Phone + Country Code
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
                          onChanged: (country) {
                            setState(() {
                              _countryCode = country.dialCode ?? "+91";
                            });
                          },
                          initialSelection: 'IN',
                          favorite: const ['+91', 'IN'],
                          countryFilter: const ['IN'],
                          showDropDownButton: false,
                          showFlag: false,
                          textStyle: TextStyle(color: const Color(0xFF616161), fontSize: inputFontSize),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Container(
                          height: inputHeight,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          alignment: Alignment.centerLeft,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF2F4F5),
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: TextField(
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(10),
                            ],
                            decoration: InputDecoration(
                              hintText: 'Mobile Number',
                              hintStyle: TextStyle(color: const Color(0xFF616161), fontSize: inputFontSize),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: spacingSmall),

                  // Password
                  Container(
                    height: inputHeight,
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    alignment: Alignment.centerLeft,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF2F4F5),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: TextField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        hintText: 'Password',
                        hintStyle: TextStyle(color: const Color(0xFF616161), fontSize: inputFontSize),
                        border: InputBorder.none,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword ? Icons.visibility_off : Icons.visibility,
                            color: const Color(0xFF616161),
                          ),
                          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: spacingLarge),

                  // Register Button
                  GestureDetector(
                    onTap: _register,
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(vertical: paddingVertical),
                      decoration: ShapeDecoration(
                        color: const Color(0xFFCCF656),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                      ),
                      child: Center(
                        child: Text(
                          'Verify Phone',
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

                  // "Back to Login" Navigation
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Text.rich(
                      TextSpan(
                        children: [
                          const TextSpan(
                            text: 'Already have an account? ',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 14,
                              fontFamily: 'Plus Jakarta Sans',
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          TextSpan(
                            text: 'Login',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 14,
                              fontFamily: 'Plus Jakarta Sans',
                              fontWeight: FontWeight.w700,
                              decoration: TextDecoration.underline,
                              decorationColor: Colors.black,
                              decorationThickness: 2,
                            ),
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(height: spacingLarge),

                  // Terms & Conditions
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: 'By continuing you are accepting all\n',
                          style: TextStyle(color: Colors.black, fontSize: inputFontSize, fontWeight: FontWeight.w400),
                        ),
                        TextSpan(
                          text: 'Terms & Conditions',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: inputFontSize,
                            fontWeight: FontWeight.w700,
                            decoration: TextDecoration.underline,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const PolicyScreen(title: "Terms & Conditions"),
                                ),
                              );
                            },
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),

        // Loading overlay
        if (_isLoading)
          Container(
            color: Colors.black.withOpacity(0.5),
            alignment: Alignment.center,
            child: const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
      ],
    );
  }
}
