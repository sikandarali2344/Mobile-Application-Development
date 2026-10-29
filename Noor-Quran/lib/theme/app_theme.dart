import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Islamic-inspired colors
  static const Color emerald = Color(0xFF0F766E);
  static const Color gold = Color(0xFFD4AF37);
  static const Color deepTeal = Color(0xFF0A4A47);
  static const Color cream = Color(0xFFFAF6EC);
  static const Color nightBlue = Color(0xFF0B1220);
  static const Color nightCard = Color(0xFF16202E);
  static const Color amber = Color(0xFFE9B949);

  static ThemeData lightTheme() {
    final base = ThemeData.light(useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: cream,
      colorScheme: base.colorScheme.copyWith(
        primary: emerald,
        secondary: gold,
        surface: Colors.white,
      ),
      textTheme: GoogleFonts.poppinsTextTheme(base.textTheme),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
    );
  }

  static ThemeData darkTheme() {
    final base = ThemeData.dark(useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: nightBlue,
      colorScheme: base.colorScheme.copyWith(
        primary: emerald,
        secondary: gold,
        surface: nightCard,
      ),
      textTheme: GoogleFonts.poppinsTextTheme(base.textTheme),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
    );
  }
}