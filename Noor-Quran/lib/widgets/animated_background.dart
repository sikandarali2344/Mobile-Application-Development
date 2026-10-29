import 'dart:math' as math;
import 'package:flutter/material.dart';

class AnimatedBackground extends StatefulWidget {
  const AnimatedBackground({super.key});

  @override
  State<AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return CustomPaint(
          painter: _BgPainter(_controller.value, isDark),
          size: Size.infinite,
        );
      },
    );
  }
}

class _BgPainter extends CustomPainter {
  final double t;
  final bool isDark;

  _BgPainter(this.t, this.isDark);

  @override
  void paint(Canvas canvas, Size size) {
    final bg = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: isDark
            ? const [
                Color(0xFF0B1220),
                Color(0xFF0A4A47),
                Color(0xFF16202E),
              ]
            : const [
                Color(0xFFFAF6EC),
                Color(0xFFE8F3EE),
                Color(0xFFF5EEDB),
              ],
      ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, bg);

    _glow(canvas, size, isDark ? Color(0xFF0F766E) : Color(0xFF0F766E),
        Alignment(math.sin(t * 2 * math.pi) * 0.5, -0.7), 280);
    _glow(canvas, size, isDark ? Color(0xFFD4AF37) : Color(0xFFD4AF37),
        Alignment(math.cos(t * 2 * math.pi) * 0.5, 0.8), 240);
  }

  void _glow(Canvas canvas, Size size, Color color, Alignment align, double r) {
    final center = Offset(
      (align.x + 1) * size.width / 2,
      (align.y + 1) * size.height / 2,
    );
    final paint = Paint()
      ..shader = RadialGradient(
        colors: [
          color.withValues(alpha: 0.35),
          color.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: r));
    canvas.drawCircle(center, r, paint);
  }

  @override
  bool shouldRepaint(covariant _BgPainter old) => old.t != t;
}