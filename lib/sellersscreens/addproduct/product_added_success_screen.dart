import 'package:flutter/material.dart';

class ProductAddedSuccessScreen extends StatelessWidget {
  const ProductAddedSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    void backToHome() {
      Navigator.of(context).popUntil((route) => route.isFirst);
    }

    return Scaffold(
      backgroundColor: const Color(0xFFCCF656),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Spacer(flex: 2),

            // 1. Checkmark Icon
            Container(
              width: 130,
              height: 130,
              decoration: const BoxDecoration(
                color: Colors.black,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_rounded,
                color: Color(0xFFCCF656),
                size: 80,
              ),
            ),
            const SizedBox(height: 60),

            // 2. Main Title
            const Text(
              'Product Added\nSuccessfully',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black,
                fontSize: 30,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w700,
                height: 1.20,
              ),
            ),
            const SizedBox(height: 30),

            // 3. Subtitle
            const Text(
              'Product uploaded to inventory',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black,
                fontSize: 21,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w400,
                height: 1.43,
              ),
            ),

            const Spacer(flex: 3),

            // 4. Action Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: ElevatedButton(
                onPressed: backToHome,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  minimumSize: const Size(double.infinity, 60),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text(
                  'Back To Home Screen',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontFamily: 'Encode Sans',
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            // A bit of padding at the bottom
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
