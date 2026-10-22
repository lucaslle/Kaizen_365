import 'package:flutter/material.dart';

import '../app_palette.dart';
import '../app_text.dart';

enum AppButtonVariant { accent, dark, outline, soft, light }

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.accent,
    this.height = 56,
    this.icon,
    this.fontSize = 16,
    this.padding = 22,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final double height;
  final IconData? icon;
  final double fontSize;
  final double padding;

  @override
  Widget build(BuildContext context) {
    final (background, foreground) = switch (variant) {
      AppButtonVariant.accent => (context.palette.accent, context.palette.onAccent),
      AppButtonVariant.dark => (context.palette.inverse, context.palette.onInverse),
      AppButtonVariant.outline => (Colors.transparent, context.palette.ink),
      AppButtonVariant.soft => (context.palette.sunken, context.palette.ink),
      AppButtonVariant.light => (context.palette.accentLight, context.palette.ink),
    };
    final isEnabled = onPressed != null;
    return Opacity(
      opacity: isEnabled ? 1 : 0.4,
      child: Material(
        color: background,
        shape: StadiumBorder(
          side: variant == AppButtonVariant.outline
              ? BorderSide(color: context.palette.inputBorder, width: 1.5)
              : BorderSide.none,
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onPressed,
          child: Container(
            height: height,
            padding: EdgeInsets.symmetric(horizontal: padding),
            alignment: Alignment.center,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[Icon(icon, size: fontSize + 4, color: foreground), const SizedBox(width: 6)],
                Text(label, style: context.text.sans(fontSize, weight: 600, color: foreground)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
