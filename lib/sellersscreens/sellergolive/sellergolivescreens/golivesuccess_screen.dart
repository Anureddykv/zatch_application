import 'package:flutter/material.dart';
import 'package:zatch_app/common_widgets/appsizedbox.dart';

class GoliveAddedSuccessScreen extends StatelessWidget {
  const GoliveAddedSuccessScreen({super.key});

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
                color: Colors.white,
                size: 80,
              ),
            ),
            const SizedBox(height: 60),

            // 2. Main Title
            const Text(
              'Live Sheduled at',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black,
                fontSize: 30,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w700,
                height: 1.20,
              ),
            ),

            const Text(
              '12/12/2025 - 09:00 PM ',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black,
                fontSize: 15,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w400,
                height: 1.43,
              ),
            ),

            const Spacer(flex: 3),

            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      onPressed: () {},
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.share, color: Colors.black),
                          AppSizedBox.width10,
                          Text('Share', style: TextStyle(color: Colors.black)),
                        ],
                      ),
                    ),
                  ),
                  AppSizedBox.width10,
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        elevation: 0,

                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      onPressed: () {},
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.copy, color: Colors.black),
                          AppSizedBox.width10,
                          Text('Copy', style: TextStyle(color: Colors.black)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
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
