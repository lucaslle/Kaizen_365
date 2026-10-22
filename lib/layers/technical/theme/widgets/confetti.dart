import 'dart:math';

import 'package:flutter/material.dart';

import 'motion.dart';

/// A short burst of confetti falling over its area. Static when the system asks to reduce motion.
class Confetti extends StatefulWidget {
  const Confetti({super.key, required this.colors});

  final List<Color> colors;

  @override
  State<Confetti> createState() => _ConfettiState();
}

class _ConfettiState extends State<Confetti> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(vsync: this, duration: const Duration(seconds: 3));
  final _pieces = List.generate(60, (i) => _Piece(Random(i)));

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (Motion.duration(context, Motion.progress) == Duration.zero) {
      _controller.value = 0.35;
    } else if (!_controller.isAnimating) {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => IgnorePointer(
    child: ExcludeSemantics(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) =>
            CustomPaint(size: Size.infinite, painter: _ConfettiPainter(_pieces, _controller.value, widget.colors)),
      ),
    ),
  );
}

class _Piece {
  _Piece(Random random)
    : x = random.nextDouble(),
      delay = random.nextDouble() * 0.3,
      speed = 0.6 + random.nextDouble() * 0.6,
      drift = (random.nextDouble() - 0.5) * 0.2,
      spin = random.nextDouble() * 6,
      color = random.nextInt(1 << 16);

  final double x;
  final double delay;
  final double speed;
  final double drift;
  final double spin;
  final int color;
}

class _ConfettiPainter extends CustomPainter {
  _ConfettiPainter(this.pieces, this.t, this.colors);

  final List<_Piece> pieces;
  final double t;
  final List<Color> colors;

  @override
  void paint(Canvas canvas, Size size) {
    for (final piece in pieces) {
      final progress = ((t - piece.delay) / (1 - piece.delay)).clamp(0.0, 1.0);
      if (progress == 0) continue;
      final dx = (piece.x + piece.drift * progress) * size.width;
      final dy = -20 + progress * piece.speed * (size.height + 40);
      final paint = Paint()..color = colors[piece.color % colors.length].withValues(alpha: 1 - progress * 0.6);
      canvas
        ..save()
        ..translate(dx, dy)
        ..rotate(piece.spin * progress * pi)
        ..drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(-4, -2, 8, 4), const Radius.circular(1)), paint)
        ..restore();
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter oldDelegate) => oldDelegate.t != t;
}
