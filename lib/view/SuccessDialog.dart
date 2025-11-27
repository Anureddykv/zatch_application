import 'package:flutter/material.dart';

class SuccessDialog extends StatelessWidget {
  final String title;
  final String message;
  final String buttonText;  final VoidCallback onButtonPressed;

  const SuccessDialog({
    super.key,
    this.title = 'Success!',
    required this.message,
    this.buttonText = 'Continue',
    required this.onButtonPressed,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      backgroundColor: Colors.white,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // You can use a custom icon or image here
          const CircleAvatar(
            radius: 30,
            backgroundColor: Color(0xFFCCF656),
            child: Icon(Icons.check, color: Colors.black, size: 30),
          ),
          const SizedBox(height: 24),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF121111),
              fontSize: 18,
              fontFamily: 'Encode Sans',
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF787676),
              fontSize: 14,
              fontFamily: 'Encode Sans',
            ),
          ),
        ],
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFCCF656),
                foregroundColor: Colors.black,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              onPressed: onButtonPressed,
              child: Text(
                buttonText,
                style: const TextStyle(
                  fontSize: 14,
                  fontFamily: 'Encode Sans',
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
