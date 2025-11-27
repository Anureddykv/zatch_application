import 'dart:io';

import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:zatch_app/model/user_profile_response.dart';
import 'package:zatch_app/services/api_service.dart';
import 'package:zatch_app/view/auth_view/login.dart';

class ChangePasswordScreen extends StatefulWidget {
  final UserProfileResponse? userProfile;

  const ChangePasswordScreen({
    super.key,
    this.userProfile,
  });

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _newCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  bool _obscNew = true;
  bool _obscCon = true;
  bool _isLoading = false;

  // --- NEW: State for image handling ---
  File? _profileImageFile;
  final ImagePicker _picker = ImagePicker();

  static const brandGreen = Color(0xFFA3DD00);

  final ApiService _apiService = ApiService();

  // --- NEW: Method to get the current image provider for CircleAvatar and Previews ---
  ImageProvider? get _currentImageProvider {
    if (_profileImageFile != null) {
      // Use the new file if it exists
      return FileImage(_profileImageFile!);
    }
    if (widget.userProfile?.user.profilePic.url.isNotEmpty ?? false) {
      // Otherwise, use the network URL if it exists
      return NetworkImage(widget.userProfile!.user.profilePic.url);
    }
    // Return null if no image is available
    return null;
  }

  // --- CORRECTED: Method to pick an image from camera or gallery ---
  Future<void> _pickImage(ImageSource source) async {
    // First, close the actions dialog before opening the image picker.
    Navigator.of(context).pop();

    try {
      final pickedFile = await _picker.pickImage(source: source, imageQuality: 80);
      if (pickedFile != null) {
        setState(() {
          _profileImageFile = File(pickedFile.path);
        });
        // After picking, close the image preview dialog that is now underneath.
        Navigator.of(context).pop();
      }
    } catch (e) {
      // Handle potential errors, e.g., permissions denied
      print("Image picker error: $e");
      // If picking is cancelled or fails, we might need to pop the preview as well
      if(Navigator.of(context).canPop()){
        Navigator.of(context).pop();
      }
    }
  }

  // --- CORRECTED: Method to delete the current image ---
  void _deleteImage() {
    setState(() {
      _profileImageFile = null;
      // TODO: Add an API call here to delete the user's profile picture from the server.
    });
    // Close the options dialog and then the preview dialog
    Navigator.of(context).pop(); // Closes _showImageActionsDialog
    Navigator.of(context).pop(); // Closes _showImagePreviewDialog
  }

  // --- NEW: Shows the dialog with "Take Photo", "Upload", "Delete" options ---
  void _showImageActionsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // This dialog is styled to match the Figma design
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          backgroundColor: Colors.white,
          contentPadding: EdgeInsets.zero,
          content: Container(
            width: 165,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDialogActionItem('Take Photo', () => _pickImage(ImageSource.camera)),
                const Divider(height: 1, indent: 16, endIndent: 16),
                _buildDialogActionItem('Upload', () => _pickImage(ImageSource.gallery)),
                const Divider(height: 1, indent: 16, endIndent: 16),
                _buildDialogActionItem('Delete', _deleteImage, color: Colors.red.shade700),
              ],
            ),
          ),
        );
      },
    );
  }

  // --- NEW: Helper widget for building the list items in the actions dialog ---
  Widget _buildDialogActionItem(String title, VoidCallback onTap, {Color color = const Color(0xFF6A7282)}) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: color,
            fontSize: 16,
            fontFamily: 'Source Sans Pro',
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );
  }

  // --- NEW: Shows the full-screen circular image preview as per the Figma design ---
  void _showImagePreviewDialog() {
    final imageProvider = _currentImageProvider;

    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.5), // Semi-transparent background
      builder: (BuildContext context) {
        return Scaffold(
          backgroundColor: Colors.transparent, // Important for the barrierColor to be visible
          body: Stack(
            alignment: Alignment.center,
            children: [
              // The main circular image preview
              GestureDetector(
                onTap: () => Navigator.of(context).pop(), // Tap background to dismiss
                child: Container(
                  color: Colors.transparent,
                ),
              ),
              Container(
                width: 323,
                height: 323,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey[200], // Placeholder color
                  boxShadow: const [
                    BoxShadow(color: Color(0x3F000000), blurRadius: 4, offset: Offset(0, 4))
                  ],
                  image: imageProvider != null
                      ? DecorationImage(image: imageProvider, fit: BoxFit.cover)
                      : null,
                ),
                child: imageProvider == null
                    ? const Icon(Icons.person, size: 160, color: Colors.grey)
                    : null,
              ),

              // The floating edit button, positioned to match the Figma design
              Positioned(
                top: (MediaQuery.of(context).size.height / 2) + 110, // Adjust position as needed
                left: (MediaQuery.of(context).size.width / 2) + 75, // Adjust position as needed
                child: GestureDetector(
                  onTap: () {
                    // When tapped, show the action options dialog
                    _showImageActionsDialog();
                  },
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(color: Color(0x1E1A0F01), blurRadius: 4, offset: Offset(0, 1))
                      ],
                    ),
                    child: const Icon(Icons.edit, color: Colors.black, size: 24),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // --- Password validation and handling methods (unchanged) ---

  String? _validateNew(String? v) {
    final s = v?.trim() ?? "";
    if (s.isEmpty) return "Enter a new password";
    if (s.length < 8) return "At least 8 characters";
    final hasLetter = RegExp(r'[A-Za-z]').hasMatch(s);
    final hasDigit = RegExp(r'\d').hasMatch(s);
    if (!hasLetter || !hasDigit) return "Use letters & numbers";
    return null;
  }

  String? _validateConfirm(String? v) {
    if (v == null || v.isEmpty) return "Re-enter the password";
    if (v.trim() != _newCtrl.text.trim()) return "Passwords don’t match";
    return null;
  }

  Future<void> _handleChangePassword() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final response = await _apiService.changePassword(
        newPassword: _newCtrl.text.trim(),
        confirmPassword: _confirmCtrl.text.trim(),
      );

      if (mounted) {
        if (response['success'] == true) {
          Flushbar(
            title: "Success",
            message: response['message'] ?? 'Password changed successfully!',
            duration: const Duration(seconds: 3),
            backgroundColor: Colors.green,
            margin: const EdgeInsets.all(8),
            borderRadius: BorderRadius.circular(8),
            icon: const Icon(Icons.check_circle_outline, size: 28.0, color: Colors.white),
            flushbarPosition: FlushbarPosition.TOP,
          ).show(context);
          _newCtrl.clear();
          _confirmCtrl.clear();
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const LoginScreen()),
                (route) => false,
          );
        } else {
          Flushbar(
            title: "Error",
            message: response['message'] ?? 'Failed to change password',
            duration: const Duration(seconds: 3),
            backgroundColor: Colors.red,
            margin: const EdgeInsets.all(8),
            borderRadius: BorderRadius.circular(8),
            icon: const Icon(Icons.error_outline, size: 28.0, color: Colors.white),
            flushbarPosition: FlushbarPosition.TOP,
          ).show(context);
        }
      }
    } catch (e) {
      if(mounted) {
        Flushbar(
          title: "Error",
          message: e.toString(),
          duration: const Duration(seconds: 3),
          backgroundColor: Colors.red,
          margin: const EdgeInsets.all(8),
          borderRadius: BorderRadius.circular(8),
          icon: const Icon(Icons.error_outline, size: 28.0, color: Colors.white),
          flushbarPosition: FlushbarPosition.TOP,
        ).show(context);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _newCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text("Change Password", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, spreadRadius: 2)],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Stack(
                          children: [
                            CircleAvatar(
                              radius: 40,
                              backgroundImage: _currentImageProvider,
                              child: _currentImageProvider == null
                                  ? const Icon(Icons.person, size: 40, color: Colors.grey)
                                  : null,
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: GestureDetector(
                                // --- MODIFICATION: This now triggers the preview dialog ---
                                onTap: _showImagePreviewDialog,
                                child: Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: const Color(0xFFA3DD00),
                                    border: Border.all(color: Colors.white, width: 2),
                                  ),
                                  padding: const EdgeInsets.all(4),
                                  child: const Icon(Icons.edit, color: Colors.black, size: 16),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(widget.userProfile?.user.username ?? "",
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16)),
                              Text(widget.userProfile?.user.email ?? "",
                                  style: const TextStyle(
                                      color: Colors.grey, fontSize: 13)),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),
                    const Divider(thickness: 1, color: Color(0xFFEAEAEA)),
                    const SizedBox(height: 16),

                    const Text(
                      "Current Password",
                      style: TextStyle(
                        color: Color(0xFF626262),
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF6F6F6),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Row(
                        children: [
                          Expanded(
                            child: Text(
                              '************',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    TextFormField(
                      controller: _newCtrl,
                      obscureText: _obscNew,
                      decoration: _inputDecoration(
                        label: "Enter New Password",
                        toggle: () => setState(() => _obscNew = !_obscNew),
                        obscured: _obscNew,
                      ),
                      validator: _validateNew,
                    ),
                    const SizedBox(height: 12),

                    TextFormField(
                      controller: _confirmCtrl,
                      obscureText: _obscCon,
                      decoration: _inputDecoration(
                        label: "Re-Enter New Password",
                        toggle: () => setState(() => _obscCon = !_obscCon),
                        obscured: _obscCon,
                      ),
                      validator: _validateConfirm,
                    ),
                    const SizedBox(height: 28),

                    // Buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: brandGreen, width: 1.5),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30)),
                              padding:
                              const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: const Text("Cancel",
                                style: TextStyle(color: Colors.black)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleChangePassword,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: brandGreen,
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30)),
                          padding:
                          const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.black,
                            strokeWidth: 2,
                          ),
                        )
                            : const Text(
                          "Save Changes",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String label,
    required VoidCallback toggle,
    required bool obscured,
  }) {
    return InputDecoration(
      hintText: label,
      filled: true,
      fillColor: const Color(0xFFF6F6F6),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      suffixIcon: IconButton(
        icon: Icon(obscured ? Icons.visibility_off : Icons.visibility),
        onPressed: toggle,
      ),
      contentPadding:
      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }
}
