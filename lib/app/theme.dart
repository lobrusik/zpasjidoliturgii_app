import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Color palette
  static const Color _backgroundDark = Color(0xFF0F1014);
  static const Color _surfaceDark = Color(0xFF1A1C23);
  static const Color _primaryOrange = Color(0xFFE68A00);
  static const Color _textWhite = Color(0xFFF8FAFC);
  static const Color _textGrey = Color(0xFF94A3B8);
  static const Color _successGreen = Color(0xFF2E7D32);

  static ThemeData get darkTheme {
    final baseTextTheme = GoogleFonts.interTextTheme(ThemeData.dark().textTheme);

    return ThemeData(
      brightness: Brightness.dark,
      useMaterial3: true,
      scaffoldBackgroundColor: _backgroundDark,
      
      colorScheme: const ColorScheme.dark(
        primary: _primaryOrange,
        surface: _surfaceDark,
        background: _backgroundDark,
        onSurface: _textWhite,
      ),

      textTheme: baseTextTheme.copyWith(
        headlineLarge: baseTextTheme.headlineLarge?.copyWith(
          fontSize: 28, fontWeight: FontWeight.bold, color: _textWhite, height: 1.2,
        ),
        titleLarge: baseTextTheme.titleLarge?.copyWith(
          fontSize: 20, fontWeight: FontWeight.bold, color: _textWhite,
        ),
        titleMedium: baseTextTheme.titleMedium?.copyWith(
          fontSize: 16, fontWeight: FontWeight.w600, color: _textWhite,
        ),
        bodyLarge: baseTextTheme.bodyLarge?.copyWith(
          fontSize: 16, color: _textGrey, height: 1.5,
        ),
        bodyMedium: baseTextTheme.bodyMedium?.copyWith(
          fontSize: 14, color: _textGrey,
        ),
      ),

      cardTheme: CardThemeData(
        color: _surfaceDark,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFF2D3039), width: 1), // frame
        ),
        margin: const EdgeInsets.only(bottom: 16),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _primaryOrange,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),

      appBarTheme: AppBarTheme(
        backgroundColor: _backgroundDark,
        foregroundColor: _textWhite,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: _textWhite),
      ),
    );
  }
}