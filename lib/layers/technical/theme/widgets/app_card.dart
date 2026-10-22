import 'package:flutter/material.dart';

import '../app_palette.dart';

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
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: padding,
    decoration: BoxDecoration(
      color: color ?? context.palette.surface,
      borderRadius: BorderRadius.circular(radius),
      border: hasBorder ? Border.all(color: borderColor ?? context.palette.border, width: isDashed ? 1.5 : 1) : null,
    ),
    child: child,
  );
}
