import 'package:flutter/painting.dart';

import 'app_colors.dart';

abstract final class AppText {
  static const _sans = 'BricolageGrotesque';
  static const _mono = 'JetBrainsMono';

  static TextStyle sans(double size, {double weight = 400, double? height, double tracking = 0, Color color = AppColors.ink}) =>
      _style(_sans, size, weight, height, tracking, color);

  static TextStyle mono(double size, {double weight = 500, double? height, double tracking = 0, Color color = AppColors.ink}) =>
      _style(_mono, size, weight, height, tracking, color);

  static TextStyle _style(String family, double size, double weight, double? height, double tracking, Color color) =>
      TextStyle(
        fontFamily: family,
        fontSize: size,
        fontWeight: FontWeight.values[(weight ~/ 100 - 1).clamp(0, 8)],
        fontVariations: [FontVariation.weight(weight)],
        height: height,
        letterSpacing: tracking * size,
        color: color,
      );

  static final heroTitle = sans(46, weight: 700, height: 0.98, tracking: -0.035);
  static final onboardingTitle = sans(40, weight: 700, height: 1, tracking: -0.035);
  static final screenTitle = sans(32, weight: 700, height: 1.05, tracking: -0.03);
  static final stepTitle = sans(30, weight: 700, height: 1.05, tracking: -0.03);
  static final sheetTitle = sans(22, weight: 600, tracking: -0.02);
  static final sectionTitle = sans(20, weight: 600, tracking: -0.02);
  static final cardTitle = sans(20, weight: 600, height: 1.15, tracking: -0.02);
  static final bodyLarge = sans(17, height: 1.45, color: AppColors.muted);
  static final body = sans(15, height: 1.45);
  static final bodyMuted = sans(15, height: 1.45, color: AppColors.muted);
  static final small = sans(14, color: AppColors.muted);
  static final label = sans(14, weight: 500);
  static final caption = sans(13, color: AppColors.muted);
  static final button = sans(16, weight: 600);
  static final overline = mono(13, tracking: 0.05, color: AppColors.muted);
  static final monoSmall = mono(12, color: AppColors.muted);
}
