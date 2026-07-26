import 'package:flutter/material.dart';

class AppTheme {
  static final ThemeData neonTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xFF0D0015), // Deep Purple/Black
    primaryColor: const Color(0xFFFF007F), // Neon Pink
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFFFF007F),
      secondary: Color(0xFF00FFFF), // Neon Cyan
      tertiary: Color(0xFF39FF14), // Neon Green
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: Color(0xFF00FFFF),
        fontSize: 24,
        fontWeight: FontWeight.bold,
        letterSpacing: 2,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFFF007F),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        elevation: 10,
        shadowColor: const Color(0xFFFF007F).withOpacity(0.5),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white.withOpacity(0.05),
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Color(0xFF00FFFF)),
        borderRadius: BorderRadius.circular(15),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Color(0xFFFF007F), width: 2),
        borderRadius: BorderRadius.circular(15),
      ),
    ),
  );
}
