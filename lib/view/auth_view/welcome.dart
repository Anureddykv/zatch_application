import 'package:flutter/material.dart';
import 'package:zatch/view/auth_view/login.dart';
import '../../controller/auth_controller/welcome_controller.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = WelcomeController();

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            /// White background with rounded bottom
            Container(
              height: MediaQuery.of(context).size.height,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(40)),
              ),
            ),

            /// Top right concentric circles
            Positioned(
              top: -35,
              right: -100,
              child: _circleBorder(context, 350, 250),
            ),
            Positioned(
              top: -25,
              right: -90,
              child: _circleBorder(context, 300, 200),
            ),

            /// Bottom left angled boxes
            Positioned(
              bottom: 180,
              left: -30,
              child: Transform.rotate(
                angle: -0.5,
                child: _angledBox(context, 120, 200),
              ),
            ),
            Positioned(
              bottom: 180,
              left: -30,
              child: _angledBox(context, 120, 300),
            ),

            /// Main content
            Column(
              children: [
                const Spacer(flex: 3),

                /// Logo
                Image.asset(
                  'assets/images/logo.png',
                  height: 80,
                  width: 80,
                ),

                const SizedBox(height: 12),

                /// App Name
                Image.asset(
                  'assets/images/zatch.png',
                  height: 80,
                  width: 80,
                ),

                const Spacer(flex: 2),

                /// Bottom section
                Container(
                  width: double.infinity,
                  height: 260,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                          fontSize: 24,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "Welcome to India's first Live Shopping Bazaar",
                        style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      const Spacer(),

                      /// Buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          /// Login
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pushNamed(context, '/login');
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 48,
                                vertical: 14,
                              ),
                              elevation: 0,
                            ),
                            child: const Text("Login",style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontSize: 20
                            )),
                          ),

                          /// Register
                          OutlinedButton(
                            onPressed: () {
                              Navigator.pushNamed(context, '/register');
                            },
                            style: OutlinedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.black,
                              side: const BorderSide(color: Colors.white),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 48,
                                vertical: 14,
                              ),
                            ),
                            child: const Text("Register",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                                  fontSize: 20
                              ),),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Helper: Circle border
  Widget _circleBorder(BuildContext context, double w, double h) {
    return Container(
      width: w,
      height: h,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          width: 2,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  /// Helper: Angled box
  Widget _angledBox(BuildContext context, double w, double h) {
    return Container(
      width: w,
      height: h,
      decoration: BoxDecoration(
        border: Border.all(
          color: Theme.of(context).colorScheme.primary,
          width: 3,
        ),
      ),
    );
  }
}
