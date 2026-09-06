import 'package:flutter/material.dart';

class ElderlyTheme {
  // Calming, high-contrast, healthcare-friendly palette
  static const Color primaryBlue = Color(0xFF0369A1); // WCAG AAA compliant contrast
  static const Color primaryBlueDark = Color(0xFF0C4A6E);
  static const Color backgroundLight = Color(0xFFF8FAFC);
  static const Color cardSurface = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF334155);
  static const Color successGreen = Color(0xFF15803D);
  static const Color amberWarning = Color(0xFFB45309);
  static const Color borderSubtle = Color(0xFFCBD5E1);

  // Elderly Touch Target Standard
  static const double minTouchTargetSize = 56.0;

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryBlue,
        primary: primaryBlue,
        surface: cardSurface,
        onSurface: textPrimary,
      ),
      scaffoldBackgroundColor: backgroundLight,
      fontFamily: 'Roboto',
      textTheme: const TextTheme(
        headlineLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: textPrimary, height: 1.3),
        headlineMedium: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: textPrimary, height: 1.3),
        titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: textPrimary),
        bodyLarge: TextStyle(fontSize: 19, fontWeight: FontWeight.normal, color: textSecondary, height: 1.4),
        bodyMedium: TextStyle(fontSize: 17, fontWeight: FontWeight.normal, color: textSecondary),
        labelLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, minTouchTargetSize),
          backgroundColor: primaryBlue,
          foregroundColor: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
      cardTheme: CardThemeData(
        color: cardSurface,
        elevation: 1.5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: borderSubtle, width: 1.2),
        ),
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
      ),
    );
  }
}
