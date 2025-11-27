import 'package:flutter/material.dart';
import 'package:zatch_app/view/home_page.dart';

class OrderPlacedScreen extends StatefulWidget {
  const OrderPlacedScreen({super.key});

  @override
  State<OrderPlacedScreen> createState() => _OrderPlacedScreenState();
}

class _OrderPlacedScreenState extends State<OrderPlacedScreen> {
  bool _isNavigating = false;
  void _navigateToHome() {
    if (_isNavigating || !mounted) return;
    setState(() {
      _isNavigating = true;
    });
 Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const HomePage()),
          (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (bool didPop) {
        if (didPop) return;
        _navigateToHome();
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFCCFF55),
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              const CircleAvatar(
                radius: 40,
                backgroundColor: Colors.black,
                child: Icon(Icons.check, color: Colors.white, size: 40),
              ),
              const SizedBox(height: 20),
              const Text(
                "Order Placed",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Order ID - 1231231231234\nis successful placed",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black87),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: _navigateToHome,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text("Back To Home Screen"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
