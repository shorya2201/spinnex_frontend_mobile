import 'package:flutter/material.dart';

class AppTheme {
  // Base Off-White Palette
  static const Color offWhiteBackground = Color(0xFFF8F9FD);
  static const List<Color> offWhiteGradient = [
    Color(0xFFF8F9FD),
    Color(0xFFF1F5F9),
    Color(0xFFEAF0F8),
  ];
  static const Color surfaceWhite = Color(0xFFFFFFFF);
  static const Color textDarkSlate = Color(0xFF0F172A);
  static const Color textSubtleSlate = Color(0xFF64748B);
  static const Color borderLight = Color(0xFFE2E8F0);

  // Neon Secondary Accents & Details
  static const Color neonPink = Color(0xFFFF007F);
  static const Color neonCyan = Color(0xFF00D8F6);
  static const Color neonGreen = Color(0xFF10B981);
  static const Color neonAmber = Color(0xFFFFB800);

  static final ThemeData offWhiteNeonTheme = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: offWhiteBackground,
    primaryColor: neonPink,
    colorScheme: const ColorScheme.light(
      primary: neonPink,
      secondary: neonCyan,
      tertiary: neonGreen,
      surface: surfaceWhite,
      onSurface: textDarkSlate,
      onPrimary: Colors.white,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: textDarkSlate),
      titleTextStyle: TextStyle(
        color: textDarkSlate,
        fontSize: 22,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.2,
      ),
    ),
    cardTheme: CardThemeData(
      color: surfaceWhite,
      elevation: 4,
      shadowColor: textDarkSlate.withOpacity(0.06),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: borderLight, width: 1),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: neonPink,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        elevation: 6,
        shadowColor: neonPink.withOpacity(0.35),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surfaceWhite,
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: borderLight, width: 1.5),
        borderRadius: BorderRadius.circular(16),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: neonPink, width: 2),
        borderRadius: BorderRadius.circular(16),
      ),
      hintStyle: const TextStyle(color: textSubtleSlate),
    ),
  );

  // Legacy neon theme reference kept for compatibility
  static final ThemeData neonTheme = offWhiteNeonTheme;
}
