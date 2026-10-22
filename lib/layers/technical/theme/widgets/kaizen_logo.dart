import 'dart:math';

import 'package:flutter/material.dart';

import '../app_colors.dart';

class KaizenLogo extends StatelessWidget {
  const KaizenLogo({super.key, required this.size});

  final double size;

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(size * 0.24),
          child: CustomPaint(size: Size.square(size), painter: const _KaizenLogoPainter()),
        ),
      );
}

class _KaizenLogoPainter extends CustomPainter {
  const _KaizenLogoPainter();

  static const _pastMonths = 9;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 100);
    canvas.drawRect(const Rect.fromLTWH(0, 0, 100, 100), Paint()..color = AppColors.ink);
    for (var month = 0; month < 12; month++) {
      final color = month < _pastMonths
          ? AppColors.onAccent
          : month == _pastMonths
              ? AppColors.accentLight
              : AppColors.ink2;
      canvas
        ..save()
        ..translate(50, 50)
        ..rotate(month * pi / 6)
        ..translate(-50, -50)
        ..drawRRect(RRect.fromLTRBR(47, 10, 53, 22, const Radius.circular(3)), Paint()..color = color)
        ..restore();
    }
    final mountain = Path()
      ..moveTo(26, 68)
      ..lineTo(46, 36)
      ..lineTo(56, 50)
      ..lineTo(62, 43)
      ..lineTo(74, 68)
      ..close();
    canvas.drawPath(mountain, Paint()..color = AppColors.ink2);
    final trail = Path()
      ..moveTo(30, 64)
      ..quadraticBezierTo(38, 60, 40, 54)
      ..quadraticBezierTo(42, 48, 46, 40);
    final dotPaint = Paint()..color = AppColors.onAccent;
    for (final metric in trail.computeMetrics()) {
      for (var d = 0.25; d < metric.length; d += 6.5) {
        canvas.drawCircle(metric.getTangentForOffset(d)!.position, 1.6, dotPaint);
      }
    }
    canvas.drawCircle(const Offset(46, 38), 4, Paint()..color = AppColors.accentLight);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
