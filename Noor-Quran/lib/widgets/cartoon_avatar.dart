import 'dart:math' as math;

import 'package:flutter/material.dart';

class CartoonAvatar extends StatefulWidget {
  const CartoonAvatar({super.key});

  @override
  State<CartoonAvatar> createState() => _CartoonAvatarState();
}

class _CartoonAvatarState extends State<CartoonAvatar>
    with TickerProviderStateMixin {
  late final AnimationController _bounceController;
  late final AnimationController _blinkController;

  @override
  void initState() {
    super.initState();
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _blinkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    )..repeat(period: const Duration(seconds: 3));
  }

  @override
  void dispose() {
    _bounceController.dispose();
    _blinkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_bounceController, _blinkController]),
      builder: (context, _) {
        final bounce = math.sin(_bounceController.value * math.pi) * 12;
        return Transform.translate(
          offset: Offset(0, -bounce),
          child: SizedBox(
            width: 160,
            height: 160,
            child: CustomPaint(painter: _AvatarPainter(_blinkController.value)),
          ),
        );
      },
    );
  }
}

class _AvatarPainter extends CustomPainter {
  const _AvatarPainter(this.blink);

  final double blink;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final skinPaint = Paint()..color = const Color(0xFFFFDBAC);
    canvas.drawCircle(center, radius, skinPaint);

    final hairPaint = Paint()..color = const Color(0xFF3D2C29);
    final hairPath = Path()
      ..moveTo(center.dx - radius, center.dy)
      ..lineTo(center.dx - radius * 0.85, center.dy - 18)
      ..arcTo(
        Rect.fromCircle(
          center: Offset(center.dx, center.dy - 8),
          radius: radius * 0.84,
        ),
        math.pi,
        math.pi,
        false,
      )
      ..lineTo(center.dx + radius, center.dy)
      ..close();
    canvas.drawPath(hairPath, hairPaint);

    final cheekPaint = Paint()
      ..color = const Color(0xFFFF9AA2).withValues(alpha: 0.7);
    canvas.drawCircle(
      Offset(center.dx - radius * 0.45, center.dy + radius * 0.25),
      radius * 0.13,
      cheekPaint,
    );
    canvas.drawCircle(
      Offset(center.dx + radius * 0.45, center.dy + radius * 0.25),
      radius * 0.13,
      cheekPaint,
    );

    final eyeHeight = radius * 0.18 * (1 - blink);
    final eyePaint = Paint()..color = const Color(0xFF1F1F1F);
    final eyeY = center.dy - radius * 0.15;
    final eyeX1 = center.dx - radius * 0.35;
    final eyeX2 = center.dx + radius * 0.35;
    final eyeWidth = radius * 0.14;

    if (eyeHeight > 2) {
      final whitePaint = Paint()..color = Colors.white;
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(eyeX1, eyeY),
          width: eyeWidth,
          height: eyeHeight * 1.4,
        ),
        eyePaint,
      );
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(eyeX2, eyeY),
          width: eyeWidth,
          height: eyeHeight * 1.4,
        ),
        eyePaint,
      );
      canvas.drawCircle(Offset(eyeX1 + 2, eyeY - 3), 2.5, whitePaint);
      canvas.drawCircle(Offset(eyeX2 + 2, eyeY - 3), 2.5, whitePaint);
    } else {
      canvas.drawLine(
        Offset(eyeX1 - eyeWidth, eyeY),
        Offset(eyeX1 + eyeWidth, eyeY),
        Paint()
          ..color = const Color(0xFF1F1F1F)
          ..strokeWidth = 2.5
          ..strokeCap = StrokeCap.round,
      );
      canvas.drawLine(
        Offset(eyeX2 - eyeWidth, eyeY),
        Offset(eyeX2 + eyeWidth, eyeY),
        Paint()
          ..color = const Color(0xFF1F1F1F)
          ..strokeWidth = 2.5
          ..strokeCap = StrokeCap.round,
      );
    }

    final smilePath = Path()
      ..moveTo(center.dx - radius * 0.25, center.dy + radius * 0.35)
      ..quadraticBezierTo(
        center.dx,
        center.dy + radius * 0.6,
        center.dx + radius * 0.25,
        center.dy + radius * 0.35,
      );

    canvas.drawPath(
      smilePath,
      Paint()
        ..color = const Color(0xFF1F1F1F)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant _AvatarPainter old) => old.blink != blink;
}
