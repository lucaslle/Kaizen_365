import 'package:flutter/material.dart';

import '../app_text.dart';

class StatusPill extends StatelessWidget {
  const StatusPill({
    super.key,
    required this.icon,
    required this.label,
    required this.foreground,
    required this.background,
    this.height = 26,
    this.fontWeight = 600,
    this.fontSize = 13,
  });

  final IconData icon;
  final String label;
  final Color foreground;
  final Color background;
  final double height;
  final double fontWeight;
  final double fontSize;

  @override
  Widget build(BuildContext context) => Container(
        height: height,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(height / 2)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, fill: 1, color: foreground),
            const SizedBox(width: 6),
            Text(label, style: AppText.sans(fontSize, weight: fontWeight, color: foreground)),
          ],
        ),
      );
}
