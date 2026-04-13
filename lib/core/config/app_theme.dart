import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF0D47A1), // Deep Blue as requested
        primary: const Color(0xFF0D47A1),
        secondary: const Color(0xFF1976D2),
      ),
      useMaterial3: true,
      fontFamily: 'Roboto', // Default fallback modern font if Google fonts not installed
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }
}
