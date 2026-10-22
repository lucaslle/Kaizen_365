import 'package:flutter/material.dart';

import '../app_colors.dart';
import 'motion.dart';

class ChoiceTile extends StatelessWidget {
  const ChoiceTile({
    super.key,
    required this.isSelected,
    required this.onTap,
    required this.child,
    this.selectedBorder = AppColors.ink,
    this.idleBorder = AppColors.border,
    this.selectedFill = AppColors.surface,
    this.idleFill = Colors.transparent,
    this.radius = 16,
    this.height,
    this.padding = const EdgeInsets.symmetric(horizontal: 16),
    this.isRadio = false,
  });

  final bool isSelected;
  final VoidCallback onTap;
  final Widget child;
  final Color selectedBorder;
  final Color idleBorder;
  final Color selectedFill;
  final Color idleFill;
  final double radius;
  final double? height;
  final EdgeInsetsGeometry padding;
  final bool isRadio;

  @override
  Widget build(BuildContext context) => Semantics(
        button: true,
        selected: isSelected,
        inMutuallyExclusiveGroup: isRadio,
        checked: isRadio ? isSelected : null,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(radius),
            child: AnimatedContainer(
              duration: Motion.duration(context, Motion.quick),
              height: height,
              padding: padding,
              constraints: const BoxConstraints(minHeight: 44),
              decoration: BoxDecoration(
                color: isSelected ? selectedFill : idleFill,
                borderRadius: BorderRadius.circular(radius),
                border: Border.all(color: isSelected ? selectedBorder : idleBorder, width: 1.5),
              ),
              child: child,
            ),
          ),
        ),
      );
}
