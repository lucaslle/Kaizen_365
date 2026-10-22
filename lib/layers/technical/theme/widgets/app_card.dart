import 'package:flutter/material.dart';

import '../app_palette.dart';
import 'dashed_border_painter.dart';

class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.radius = 22,
    this.color,
    this.borderColor,
    this.hasBorder = true,
    this.isDashed = false,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final Color? color;
  final Color? borderColor;
  final bool hasBorder;
  final bool isDashed;

  @override
  Widget build(BuildContext context) {
    final lineColor = borderColor ?? context.palette.border;
    final card = Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: color ?? context.palette.surface,
        borderRadius: BorderRadius.circular(radius),
        border: hasBorder && !isDashed ? Border.all(color: lineColor) : null,
      ),
      child: child,
    );
    if (!hasBorder || !isDashed) return card;
    return CustomPaint(
      foregroundPainter: DashedBorderPainter(color: lineColor, radius: radius),
      child: card,
    );
  }
}
