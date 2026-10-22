import 'package:flutter/material.dart';

import '../app_colors.dart';

class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.radius = 22,
    this.color = AppColors.surface,
    this.borderColor = AppColors.border,
    this.isDashed = false,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final Color color;
  final Color? borderColor;
  final bool isDashed;

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: padding,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(radius),
          border: borderColor == null ? null : Border.all(color: borderColor!, width: isDashed ? 1.5 : 1),
        ),
        child: child,
      );
}
