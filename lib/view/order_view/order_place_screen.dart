import 'package:flutter/material.dart';

import '../home_page.dart';

class OrderPlacedScreen extends StatelessWidget {
  final String? orderId;

  const OrderPlacedScreen({super.key, this.orderId});

  @override
  Widget build(BuildContext context) {
    // Determine the ID text to display
    final String displayId = (orderId != null && orderId!.isNotEmpty)
        ? orderId!
        : 'Unknown';

    return PopScope(
      canPop: false, // Prevent back button
      child: Scaffold(
        // Figma Background Color
        backgroundColor: const Color(0xFFCCF656),
        body: SafeArea(
          child: Column(
            children: [
              const Spacer(),

              // --- Central Icon (Black Circle) ---
              Container(
                width: 130,
                height: 130,
                decoration: const BoxDecoration(
                  color: Colors.black,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  // Added a checkmark since the Figma had a placeholder box
                  child: Icon(
                    Icons.check,
                    color: Color(0xFFCCF656),
                    size: 60,
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // --- Title "Order Placed" ---
              const Text(
                'Order Placed',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 30,
                  fontFamily: 'Inter', // Or 'Plus Jakarta Sans' depending on your font assets
                  fontWeight: FontWeight.w700,
                  height: 1.0,
                ),
              ),

              const SizedBox(height: 20),

              // --- Subtitle with Order ID ---
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40.0),
                child: Text(
                  'Order ID - #$displayId is successful placed',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 21,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400,
                    height: 1.4,
                  ),
                ),
              ),

              const Spacer(),

              // --- "Back To Home Screen" Button ---
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 30),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (_) => HomePage()),
                            (Route<dynamic> route) => false,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text(
                      'Back To Home Screen',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        fontFamily: 'Encode Sans',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
