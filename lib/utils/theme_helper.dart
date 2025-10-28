import 'package:flutter/material.dart';

class ThemeHelper {
  // Theme indices
  static const int defaultDark = 0;
  static const int minimal = 1;
  static const int warrior = 2;

  // Get theme data based on index
  static ThemeData getTheme(int themeIndex) {
    switch (themeIndex) {
      case minimal:
        return _minimalTheme();
      case warrior:
        return _warriorTheme();
      case defaultDark:
      default:
        return _defaultDarkTheme();
    }
  }

  // Default Dark Theme (Blue & Emerald)
  static ThemeData _defaultDarkTheme() {
    return ThemeData(
      primarySwatch: Colors.blue,
      scaffoldBackgroundColor: const Color(0xFF0A0E21),
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFF4A90E2),
        secondary: Color(0xFF50C878),
        surface: Color(0xFF1D1E33),
        error: Color(0xFFE74C3C),
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          color: Colors.white70,
        ),
      ),
      cardColor: const Color(0xFF1D1E33),
      dividerColor: Colors.white24,
    );
  }

  // Minimal Theme (Monochrome)
  static ThemeData _minimalTheme() {
    return ThemeData(
      primarySwatch: Colors.grey,
      scaffoldBackgroundColor: const Color(0xFF121212),
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFFE0E0E0),
        secondary: Color(0xFF757575),
        surface: Color(0xFF1E1E1E),
        error: Color(0xFFCF6679),
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          color: Colors.white70,
        ),
      ),
      cardColor: const Color(0xFF1E1E1E),
      dividerColor: Colors.white24,
    );
  }

  // Warrior Theme (Red & Black)
  static ThemeData _warriorTheme() {
    return ThemeData(
      primarySwatch: Colors.red,
      scaffoldBackgroundColor: const Color(0xFF0D0D0D),
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFFE53935),
        secondary: Color(0xFFFF6F00),
        surface: Color(0xFF1A1A1A),
        error: Color(0xFFD32F2F),
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          color: Colors.white70,
        ),
      ),
      cardColor: const Color(0xFF1A1A1A),
      dividerColor: Colors.white24,
    );
  }

  // Get theme colors for specific elements
  static AppColors getColors(int themeIndex) {
    switch (themeIndex) {
      case minimal:
        return AppColors.minimal();
      case warrior:
        return AppColors.warrior();
      case defaultDark:
      default:
        return AppColors.defaultDark();
    }
  }
}

// App-specific colors for consistency
class AppColors {
  final Color background;
  final Color surface;
  final Color primary;
  final Color secondary;
  final Color success;
  final Color error;
  final Color streak;
  final Color special;

  AppColors({
    required this.background,
    required this.surface,
    required this.primary,
    required this.secondary,
    required this.success,
    required this.error,
    required this.streak,
    required this.special,
  });

  // Default Dark Colors
  factory AppColors.defaultDark() {
    return AppColors(
      background: const Color(0xFF0A0E21),
      surface: const Color(0xFF1D1E33),
      primary: const Color(0xFF4A90E2),
      secondary: const Color(0xFF50C878),
      success: const Color(0xFF50C878),
      error: const Color(0xFFE74C3C),
      streak: const Color(0xFFFF6B35),
      special: const Color(0xFF9B59B6),
    );
  }

  // Minimal Colors
  factory AppColors.minimal() {
    return AppColors(
      background: const Color(0xFF121212),
      surface: const Color(0xFF1E1E1E),
      primary: const Color(0xFFE0E0E0),
      secondary: const Color(0xFF757575),
      success: const Color(0xFF81C784),
      error: const Color(0xFFCF6679),
      streak: const Color(0xFFFFB74D),
      special: const Color(0xFFBA68C8),
    );
  }

  // Warrior Colors
  factory AppColors.warrior() {
    return AppColors(
      background: const Color(0xFF0D0D0D),
      surface: const Color(0xFF1A1A1A),
      primary: const Color(0xFFE53935),
      secondary: const Color(0xFFFF6F00),
      success: const Color(0xFF66BB6A),
      error: const Color(0xFFD32F2F),
      streak: const Color(0xFFFF8A65),
      special: const Color(0xFF7E57C2),
    );
  }
}
