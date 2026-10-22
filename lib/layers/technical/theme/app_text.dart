import 'package:flutter/material.dart';

import 'app_palette.dart';

class AppText {
  AppText(this._palette);

  static const _sans = 'BricolageGrotesque';
  static const _mono = 'JetBrainsMono';

  final AppPalette _palette;

  TextStyle sans(double size, {double weight = 400, double? height, double tracking = 0, Color? color}) =>
      _style(_sans, size, weight, height, tracking, color ?? _palette.ink);

  TextStyle mono(double size, {double weight = 500, double? height, double tracking = 0, Color? color}) =>
      _style(_mono, size, weight, height, tracking, color ?? _palette.ink);

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

  TextStyle get heroTitle => sans(46, weight: 700, height: 0.98, tracking: -0.035);
  TextStyle get onboardingTitle => sans(40, weight: 700, height: 1, tracking: -0.035);
  TextStyle get screenTitle => sans(32, weight: 700, height: 1.05, tracking: -0.03);
  TextStyle get stepTitle => sans(30, weight: 700, height: 1.05, tracking: -0.03);
  TextStyle get sheetTitle => sans(22, weight: 600, tracking: -0.02);
  TextStyle get sectionTitle => sans(20, weight: 600, tracking: -0.02);
  TextStyle get cardTitle => sans(20, weight: 600, height: 1.15, tracking: -0.02);
  TextStyle get bodyLarge => sans(17, height: 1.45, color: _palette.muted);
  TextStyle get body => sans(15, height: 1.45);
  TextStyle get bodyMuted => sans(15, height: 1.45, color: _palette.muted);
  TextStyle get small => sans(14, color: _palette.muted);
  TextStyle get label => sans(14, weight: 500);
  TextStyle get caption => sans(13, color: _palette.muted);
  TextStyle get button => sans(16, weight: 600);
  TextStyle get overline => mono(13, tracking: 0.05, color: _palette.muted);
  TextStyle get monoSmall => mono(12, color: _palette.muted);
}

extension AppTextContext on BuildContext {
  AppText get text => AppText(palette);
}
