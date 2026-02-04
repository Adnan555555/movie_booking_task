
import 'package:flutter/material.dart';

class AppTheme {
  // Light mode colors
  static const Color background = Color(0xFFEFEFEF);
  static const Color surface = Color(0xFFF5F5F5);
  static const Color primary = Color(0xFF6A4C93);
  static const Color secondary = Color(0xFFEE6C4D);
  static const Color textPrimary = Color(0xFF000000);
  static const Color textSecondary = Color(0xFF666666);
  static const Color textSecondary8F = Color(0xFF8F8F8F);
  static const Color textSecondary202C = Color(0xFF202C43);
  static const Color textColorDB = Color(0xFFDBDBDF);
  static const Color lightBlueColor = Color(0xFF61C3F2);
  static const Color navBarBackground = Color(0xFF1A1333);
  static const Color white = Color(0xFFFFFFFF);

  static ThemeData theme() {
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Poppins',
      scaffoldBackgroundColor: background,
      brightness: Brightness.light,
      colorScheme: ColorScheme.light(
        primary: primary,
        secondary: secondary,
        surface: surface,
        // background: background,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: white,
        elevation: 0,
        foregroundColor: textPrimary,
        iconTheme: IconThemeData(color: textPrimary),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 34,
          fontWeight: FontWeight.w700,
          color: textPrimary,
        ),
        displayMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        headlineMedium: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        titleLarge: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: textPrimary,
        ),
        bodyLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: textPrimary,
        ),
        bodyMedium: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: textSecondary,
        ),
      ),
    );
  }
}
