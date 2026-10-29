import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({
    super.key,
    required this.darkMode,
    required this.onThemeToggle,
  });

  final bool darkMode;
  final ValueChanged<bool> onThemeToggle;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => QuranHomeScreen(
            darkMode: widget.darkMode,
            onThemeToggle: widget.onThemeToggle,
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0A4A47),
              Color(0xFF0F766E),
              Color(0xFF16202E),
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Color(0xFFD4AF37), Color(0xFFE9B949)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFD4AF37).withValues(alpha: 0.6),
                      blurRadius: 40,
                      spreadRadius: 6,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.menu_book_rounded,
                  size: 72,
                  color: Colors.white,
                ),
              )
                  .animate(onPlay: (c) => c.repeat())
                  .shimmer(duration: 2000.ms, color: Colors.white)
                  .scale(
                    begin: const Offset(0.85, 0.85),
                    end: const Offset(1.05, 1.05),
                    duration: 1500.ms,
                  ),
              const SizedBox(height: 28),
              Text(
                'Noor Quran',
                style: GoogleFonts.amiri(
                  color: Colors.white,
                  fontSize: 44,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.4,
                ),
              ).animate().fadeIn(duration: 900.ms).slideY(begin: 0.3),
              const SizedBox(height: 10),
              Text(
                'ٱلْقُرْآنُ ٱلْكَرِيم',
                style: GoogleFonts.amiri(
                  color: const Color(0xFFE9B949),
                  fontSize: 26,
                  fontWeight: FontWeight.w500,
                ),
              ).animate().fadeIn(delay: 400.ms, duration: 900.ms),
              const SizedBox(height: 60),
              const SizedBox(
                width: 30,
                height: 30,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Color(0xFFE9B949),
                ),
              ).animate().fadeIn(delay: 800.ms),
            ],
          ),
        ),
      ),
    );
  }
}