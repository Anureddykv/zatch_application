import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zatch_app/view/auth_view/welcome.dart';
import 'package:zatch_app/view/auth_view/login.dart';
import 'package:zatch_app/view/category_screen/category_screen.dart';
import 'package:zatch_app/view/home_page.dart';

class SplashRouteDecider extends StatefulWidget {
  const SplashRouteDecider({super.key});

  @override
  State<SplashRouteDecider> createState() => _SplashRouteDeciderState();
}

class _SplashRouteDeciderState extends State<SplashRouteDecider>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _scaleAnimation = Tween<double>(begin: 1.5, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );
    _controller.forward();
    _decideRoute();
  }

  Future<void> _decideRoute() async {
    await Future.delayed(const Duration(seconds: 2));

    final prefs = await SharedPreferences.getInstance();
    final isFirstLaunch = prefs.getBool("isFirstLaunch") ?? true;
    final token = prefs.getString("authToken");
    final categories = prefs.getStringList("userCategories") ?? [];
    Widget next;

    if (isFirstLaunch) {
      next = const WelcomeScreen();
      prefs.setBool("isFirstLaunch", false);
    } else if (token == null || token.isEmpty) {
      next = const LoginScreen();
    } else if (categories.isEmpty) {
      next = const CategoryScreen();
    } else {
      next =  HomePage();
    }

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => next),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFCCF656),
      body: Center(
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                "assets/images/logo.png",
                width: 120,
                height: 120,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 20),
              Image.asset(
                "assets/images/zatch.png",
                width: 180,
                fit: BoxFit.contain,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
