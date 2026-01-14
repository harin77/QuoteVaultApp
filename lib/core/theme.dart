import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// App theme configuration
class AppTheme {
  // Color palettes
  static const Color primaryPurple = Color(0xFF7C3AED);
  static const Color primaryBlue = Color(0xFF3B82F6);
  static const Color primaryGreen = Color(0xFF10B981);
  static const Color primaryRed = Color(0xFFEF4444);
  static const Color primaryOrange = Color(0xFFF59E0B);

  /// Get Material 3 light theme
  static ThemeData getLightTheme(String accentColor) {
    final Color primaryColor = _getAccentColor(accentColor);

    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.light,
      ),
      textTheme: GoogleFonts.interTextTheme(),
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primaryColor, width: 2),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  /// Get Material 3 dark theme
  static ThemeData getDarkTheme(String accentColor) {
    final Color primaryColor = _getAccentColor(accentColor);

    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.dark,
      ),
      textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade700),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade700),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primaryColor, width: 2),
        ),
        filled: true,
        fillColor: Colors.grey.shade800,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  /// Get accent color from string
  static Color _getAccentColor(String colorName) {
    switch (colorName.toLowerCase()) {
      case 'purple':
        return primaryPurple;
      case 'blue':
        return primaryBlue;
      case 'green':
        return primaryGreen;
      case 'red':
        return primaryRed;
      case 'orange':
        return primaryOrange;
      default:
        return primaryPurple;
    }
  }

  /// Get quote card colors for light mode
  static List<Color> getQuoteCardColorsLight() {
    return [
      const Color(0xFFE0F2FE), // Light blue
      const Color(0xFFD1FAE5), // Light green
      const Color(0xFFEDE9FE), // Light purple
      const Color(0xFFFEF3C7), // Light yellow
      const Color(0xFFFCE7F3), // Light pink
      const Color(0xFFE0E7FF), // Light indigo
    ];
  }

  /// Get quote card colors for dark mode
  static List<Color> getQuoteCardColorsDark() {
    return [
      const Color(0xFF1E3A5F), // Dark blue
      const Color(0xFF1F4E3D), // Dark green
      const Color(0xFF3D2C5C), // Dark purple
      const Color(0xFF5C4A2F), // Dark yellow/brown
      const Color(0xFF5C3A4E), // Dark pink
      const Color(0xFF3D4066), // Dark indigo
    ];
  }

  /// Get quote card colors based on brightness
  static List<Color> getQuoteCardColors(Brightness brightness) {
    return brightness == Brightness.dark
        ? getQuoteCardColorsDark()
        : getQuoteCardColorsLight();
  }
}
