import 'package:flutter/material.dart';
import 'package:zatch_app/sellersscreens/addproduct/add_product_screen.dart';import 'package:zatch_app/sellersscreens/status/seller_status_screen.dart';

class RegistrationSuccessScreen extends StatelessWidget {
  const RegistrationSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (!didPop) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const SellerStatusScreen(
                status: RegistrationStatus.resumeOnboarding,
              ),
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFCCF656),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              children: [
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // ✅ Success Icon
                      Container(
                        width: 120,
                        height: 120,
                        decoration: const BoxDecoration(
                          color: Colors.black,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.check, color: Colors.white, size: 60),
                      ),
                      const SizedBox(height: 40),

                      // ✅ Title
                      const Text(
                        'Registration Submitted Successfully',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 24,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // ✅ Description
                      const Text(
                        'KYC and bank verification typically take 1–2 business days. '
                            'We will notify you as soon as verification is completed.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontFamily: 'Inter',
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.only(bottom: 20.0),
                  child: Column(
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SellerStatusScreen(
                                status: RegistrationStatus.submitted,
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFFCCF656),
                          foregroundColor: Colors.black,
                          minimumSize: const Size(double.infinity, 55),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: const BorderSide(color: Colors.black, width: 1),
                          ),
                        ),
                        child: const Text(
                          'Back to Home Screen',
                          style: TextStyle(
                            fontSize: 16,
                            fontFamily: 'Plus Jakarta Sans',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AddProductScreen(),
                            ),
                          );                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 55),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          'Add Products',
                          style: TextStyle(
                            fontSize: 16,
                            fontFamily: 'Plus Jakarta Sans',
                            fontWeight: FontWeight.w700,
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
      ),
    );
  }
}
