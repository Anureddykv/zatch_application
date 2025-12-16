import 'package:flutter/material.dart';class OrderPlacedScreen extends StatelessWidget {
  final String? orderId;

  const OrderPlacedScreen({super.key, this.orderId});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // Prevent back button from going back to checkout
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Spacer(),

                // --- Success Icon / Illustration ---
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: const Color(0xFFCCF656).withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.check_circle,
                      color: Color(0xFF94C800),
                      size: 64,
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // --- Title ---
                const Text(
                  'Order Placed Successfully!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Encode Sans',
                    color: Color(0xFF121111),
                  ),
                ),

                const SizedBox(height: 12),

                // --- Subtitle ---
                const Text(
                  'Thank you for your purchase. Your order has been received and is being processed.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF787676),
                    fontFamily: 'Encode Sans',
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 24),

                // --- Order ID Badge ---
                if (orderId != null && orderId!.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF2F4F5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Order ID: #$orderId',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                        fontFamily: 'Encode Sans',
                      ),
                    ),
                  ),

                const Spacer(),

                // --- Buttons ---

                // View Orders Button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      // Navigate to Order History (Replace route as needed)
                      // You might want to navigate to home and then switch to the profile/orders tab
                      Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: const BorderSide(color: Color(0xFF121111)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text(
                      'View My Orders',
                      style: TextStyle(
                        color: Color(0xFF121111),
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Encode Sans',
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Continue Shopping Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: const Color(0xFFCCF656),
                      foregroundColor: Colors.black,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text(
                      'Continue Shopping',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Encode Sans',
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
