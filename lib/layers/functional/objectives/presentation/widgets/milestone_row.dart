import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../../technical/theme/app_text.dart';
import '../../../../../layers/technical/theme/app_palette.dart';
import '../../domain/entities/milestone.dart';

class MilestoneRow extends StatelessWidget {
  const MilestoneRow({super.key, required this.milestone, required this.onToggle, this.size = 24, this.fontSize = 15});

  final Milestone milestone;
  final VoidCallback onToggle;
  final double size;
  final double fontSize;

  @override
  Widget build(BuildContext context) => Semantics(
    checked: milestone.isDone,
    label: milestone.title,
    excludeSemantics: true,
    child: InkWell(
      onTap: onToggle,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 48),
        child: Row(
          spacing: 12,
          children: [
            Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: milestone.isDone ? context.palette.inverse : Colors.transparent,
                border: Border.all(
                  color: milestone.isDone ? context.palette.inverse : context.palette.strongBorder,
                  width: 2,
                ),
              ),
              child: milestone.isDone
                  ? Icon(Symbols.check_rounded, size: size * 0.66, color: context.palette.onInverse)
                  : null,
            ),
            Expanded(
              child: Text(
                milestone.title,
                style: context.text
                    .sans(fontSize, height: 1.3, color: milestone.isDone ? context.palette.muted : context.palette.ink)
                    .copyWith(decoration: milestone.isDone ? TextDecoration.lineThrough : null),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
