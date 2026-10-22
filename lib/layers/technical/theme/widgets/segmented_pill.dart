import 'package:flutter/material.dart';

import '../app_colors.dart';
import '../app_text.dart';
import 'motion.dart';

class SegmentedPill<T> extends StatelessWidget {
  const SegmentedPill({super.key, required this.segments, required this.selected, required this.onSelected});

  final List<(T, String)> segments;
  final T selected;
  final ValueChanged<T> onSelected;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(color: AppColors.sunken, borderRadius: BorderRadius.circular(14)),
        child: Row(
          spacing: 4,
          children: [
            for (final (value, label) in segments)
              Expanded(
                child: Semantics(
                  button: true,
                  selected: value == selected,
                  child: GestureDetector(
                    onTap: () => onSelected(value),
                    child: AnimatedContainer(
                      duration: Motion.duration(context, Motion.quick),
                      height: 44,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: value == selected ? AppColors.surface : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: value == selected
                            ? const [BoxShadow(color: Color(0x1A000000), blurRadius: 3, offset: Offset(0, 1))]
                            : null,
                      ),
                      child: Text(label, style: AppText.sans(14, weight: value == selected ? 600 : 500)),
                    ),
                  ),
                ),
              ),
          ],
        ),
      );
}
