import 'package:flutter/material.dart';

class ThemeService {
  // Use a ValueNotifier to broadcast theme changes globally
  static final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);

  static void toggleTheme() {
    if (themeNotifier.value == ThemeMode.light) {
      themeNotifier.value = ThemeMode.dark;
    } else {
      themeNotifier.value = ThemeMode.light;
    }
  }

  static bool get isDarkMode => themeNotifier.value == ThemeMode.dark;
}
