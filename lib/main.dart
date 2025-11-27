import 'package:flutter/material.dart';
import 'package:zatch_app/services/api_service.dart';
import 'package:zatch_app/view/auth_view/login.dart';
import 'package:zatch_app/view/auth_view/register_screen.dart';
import 'package:zatch_app/view/auth_view/welcome.dart';
import 'package:zatch_app/view/help_screen.dart';
import 'package:zatch_app/view/splash_route_decider.dart';
import 'view/notification/notification_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ApiService().init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: ApiService.navigatorKey, // <- important!
      debugShowCheckedModeBanner: false,
      title: 'Zatch',
      theme: ThemeData(
        fontFamily: 'Plus Jakarta Sans',
        colorScheme: const ColorScheme.light(
          primary: Color(0xFFCCF656),
        ),
        useMaterial3: true,
      ),
      home: const SplashRouteDecider(),
      routes: {
        '/welcome': (_) => const WelcomeScreen(),
        '/login': (_) => const LoginScreen(),
        '/register': (_) => const RegisterScreen(),
        '/notification': (_) => const NotificationPage(),
        '/help': (_) => const HelpScreen(),
      },
    );
  }
}
