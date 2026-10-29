import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

import '../services/quran_storage.dart';
import '../theme/app_theme.dart';
import '../widgets/animated_background.dart';

class TasbeehScreen extends StatefulWidget {
  const TasbeehScreen({super.key});

  @override
  State<TasbeehScreen> createState() => _TasbeehScreenState();
}

class _TasbeehScreenState extends State<TasbeehScreen> {
  int _count = 0;
  int _target = 33;

  @override
  void initState() {
    super.initState();
    QuranStorage.getTasbeehCount().then((v) {
      if (mounted) setState(() => _count = v);
    });
  }

  void _increment() {
    setState(() => _count++);
    QuranStorage.setTasbeehCount(_count);
  }

  void _reset() {
    setState(() => _count = 0);
    QuranStorage.setTasbeehCount(0);
  }

  @override
  Widget build(BuildContext context) {
    final progress = (_count % _target) / _target;
    return Scaffold(
      body: Stack(
        children: [
          const Positioned.fill(child: AnimatedBackground()),
          SafeArea(
            child: Column(
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon:
                        const Icon(Icons.arrow_back_rounded, color: Colors.white),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.black.withValues(alpha: 0.25),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Tasbeeh',
                  style: GoogleFonts.amiri(
                    color: AppTheme.gold,
                    fontSize: 42,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  'سُبْحَانَ ٱللَّٰهِ',
                  style: GoogleFonts.amiri(
                    color: Colors.white,
                    fontSize: 30,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: _increment,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 260,
                        height: 260,
                        child: CircularProgressIndicator(
                          value: progress,
                          strokeWidth: 8,
                          backgroundColor: Colors.white24,
                          valueColor: const AlwaysStoppedAnimation(
                            AppTheme.gold,
                          ),
                        ),
                      ),
                      Container(
                        width: 220,
                        height: 220,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFF0F766E),
                              Color(0xFF0A4A47),
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.emerald.withValues(alpha: 0.6),
                              blurRadius: 40,
                              spreadRadius: 6,
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            '$_count',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 74,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ).animate(target: _count > 0 ? 1 : 0).scale(
                        begin: const Offset(1, 1),
                        end: const Offset(1.05, 1.05),
                        duration: 150.ms,
                      ),
                ),
                const Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _btn('Reset', Icons.refresh_rounded, _reset),
                    const SizedBox(width: 14),
                    _btn(
                      'Target $_target',
                      Icons.flag_rounded,
                      () => setState(
                        () => _target = _target == 33
                            ? 99
                            : _target == 99
                                ? 100
                                : 33,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _btn(String label, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}