import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Apple Space Aesthetic Palette
  static const Color background = Color(0xFF070709);
  static const Color surface = Color(0xFF101014);
  static const Color surfaceElevated = Color(0xFF17171E);
  static const Color surfaceHigh = Color(0xFF22222B);
  
  static const Color borderSubtle = Color(0x1AFFFFFF); // rgba(255,255,255,0.1)
  static const Color borderFaint = Color(0x0FFFFFFF);  // rgba(255,255,255,0.06)
  
  static const Color textPrimary = Color(0xFFF5F5F7);
  static const Color textSecondary = Color(0xFF86868B);
  static const Color textTertiary = Color(0xFF6E6E73);
  
  // Accents
  static const Color appleBlue = Color(0xFF2997FF);
  static const Color appleBlueHover = Color(0xFF0071E3);
  static const Color appleGold = Color(0xFFE5C07B);
  static const Color appleGoldGlow = Color(0x40E5C07B);
  static const Color royalBurgundy = Color(0xFF9E1B32);
  static const Color royalBurgundyGlow = Color(0x409E1B32);
  static const Color appleGreen = Color(0xFF30D158);
  static const Color appleOrange = Color(0xFFFF9F0A);
  static const Color appleRed = Color(0xFFFF453A);

  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: background,
    colorScheme: const ColorScheme.dark(
      primary: appleBlue,
      secondary: appleGold,
      surface: surface,
      onPrimary: Colors.white,
      onSecondary: Colors.black,
      onSurface: textPrimary,
    ),
    textTheme: GoogleFonts.interTextTheme(
      const TextTheme(
        displayLarge: TextStyle(
          fontSize: 44,
          fontWeight: FontWeight.w700,
          letterSpacing: -1.2,
          color: textPrimary,
          height: 1.15,
        ),
        displayMedium: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.8,
          color: textPrimary,
          height: 1.2,
        ),
        headlineLarge: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.5,
          color: textPrimary,
        ),
        headlineMedium: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.4,
          color: textPrimary,
        ),
        titleLarge: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.2,
          color: textPrimary,
        ),
        titleMedium: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: textPrimary,
        ),
        bodyLarge: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w400,
          color: textSecondary,
          height: 1.5,
        ),
        bodyMedium: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w400,
          color: textSecondary,
          height: 1.45,
        ),
        labelLarge: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.1,
          color: textPrimary,
        ),
        labelSmall: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.2,
          color: textTertiary,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surfaceElevated,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: borderSubtle),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: borderSubtle),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: appleBlue, width: 1.5),
      ),
      hintStyle: const TextStyle(color: textTertiary, fontSize: 14),
      labelStyle: const TextStyle(color: textSecondary, fontSize: 14),
    ),
  );
}
