import 'package:flutter/material.dart';

import '../app_palette.dart';
import 'motion.dart';

class ProgressTrack extends StatelessWidget {
  const ProgressTrack({
    super.key,
    required this.value,
    required this.color,
    this.height = 10,
    this.expected,
    this.trackColor,
    this.semanticsLabel,
  });

  final double value;
  final Color color;
  final double height;
  final double? expected;
  final Color? trackColor;
  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(height / 2);
    final markerOverflow = height / 2 - 1;
    return Semantics(
      label: semanticsLabel,
      value: '${(value * 100).round()} %',
      child: SizedBox(
        height: height,
        child: LayoutBuilder(
          builder: (context, constraints) => Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(color: trackColor ?? context.palette.sunken, borderRadius: radius),
                ),
              ),
              AnimatedContainer(
                duration: Motion.duration(context, Motion.progress),
                curve: Motion.curve,
                width: constraints.maxWidth * value.clamp(0, 1),
                decoration: BoxDecoration(color: color, borderRadius: radius),
              ),
              if (expected != null)
                Positioned(
                  left: constraints.maxWidth * expected!.clamp(0, 1),
                  top: -markerOverflow,
                  bottom: -markerOverflow,
                  child: Container(
                    width: 2,
                    decoration: BoxDecoration(color: context.palette.ink, borderRadius: BorderRadius.circular(1)),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
