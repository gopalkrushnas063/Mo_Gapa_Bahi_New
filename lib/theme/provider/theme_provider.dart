import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mogapabahi/theme/light_and_dark_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeData>((ref) {
  return ThemeNotifier();
});

class ThemeNotifier extends StateNotifier<ThemeData> {
  ThemeNotifier() : super(lightTheme) {
    loadTheme(); // Load the saved theme preference
  }

  void toggleTheme() async {
    state = state == lightTheme ? darkTheme : lightTheme;
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('isDarkMode', state == darkTheme); // Save the new theme preference
  }

  void loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final isDarkMode = prefs.getBool('isDarkMode') ?? false; // Default to light theme if no preference is saved
    state = isDarkMode ? darkTheme : lightTheme;
  }
}