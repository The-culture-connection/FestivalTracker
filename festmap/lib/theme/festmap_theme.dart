import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Colors aligned with Mockup/src/styles/theme.css
abstract final class FestMapColors {
  static const background = Color(0xFF0A0A0A);
  static const primary = Color(0xFFFF6B00);
  static const accent = Color(0xFFFFA559);
  static const card = Color(0xF2141414);
  static const mutedForeground = Color(0x80FFFFFF);
  static const inputFill = Color(0x14FF6B00);
  static const border = Color(0x33FF6B00);
}

ThemeData buildFestMapTheme() {
  final displayFont = GoogleFonts.bungee();
  final bodyFont = GoogleFonts.outfit();

  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: FestMapColors.background,
    colorScheme: const ColorScheme.dark(
      surface: FestMapColors.background,
      primary: FestMapColors.primary,
      onPrimary: Colors.black,
      secondary: Color(0xFFFF8C3A),
      onSurface: Colors.white,
    ),
    textTheme: TextTheme(
      headlineMedium: displayFont.copyWith(
        fontSize: 24,
        color: Colors.white,
        letterSpacing: -0.5,
      ),
      titleLarge: displayFont.copyWith(fontSize: 20, color: Colors.white),
      bodyMedium: bodyFont.copyWith(color: Colors.white),
      bodySmall: bodyFont.copyWith(
        color: FestMapColors.mutedForeground,
        fontSize: 12,
      ),
      labelMedium: bodyFont.copyWith(
        color: Colors.white,
        fontWeight: FontWeight.w500,
        fontSize: 14,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: FestMapColors.inputFill,
      hintStyle: bodyFont.copyWith(color: FestMapColors.mutedForeground),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: FestMapColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: FestMapColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: FestMapColors.primary, width: 2),
      ),
    ),
  );
}
