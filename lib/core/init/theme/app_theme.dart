import 'package:flutter/material.dart';

class LightTheme {
  LightTheme._();

  static ThemeData theme = ThemeData(
    colorScheme: const ColorScheme.light(
      primary: Color(0xFFAC1CF5),
      onPrimary: Color(0xFFFFFFFF),
      secondary: Color(0xFFD5D7DF),
      onSecondary: Color(0xFFFFFFFF),
      tertiary: Color(0xFFEEEEEE),
      onTertiary: Color(0xFF1A1A1A),
      surface: Color(0xFFFAFAFA),
      onSurface: Color(0xFF1A1A1A),
      surfaceContainer: Color(0xFFFFFFFF),
    ),
    inputDecorationTheme: InputDecorationTheme(
      hintStyle: TextStyle(letterSpacing: 1),
      filled: true,
      fillColor: const Color(0xFFFFFFFF),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFAC1CF5), width: 1.0),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFEEEEEE), width: 1.0),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFAC1CF5), width: 1.0),
      ),
    ),
  );
}
