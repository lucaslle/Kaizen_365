import 'package:flutter/material.dart';

class AppPalette extends ThemeExtension<AppPalette> {
  const AppPalette({
    required this.brightness,
    required this.background,
    required this.surface,
    required this.sunken,
    required this.field,
    required this.navBar,
    required this.navIndicator,
    required this.ink,
    required this.ink2,
    required this.ink3,
    required this.muted,
    required this.border,
    required this.inputBorder,
    required this.softBorder,
    required this.strongBorder,
    required this.dot,
    required this.accent,
    required this.onAccent,
    required this.accentLight,
    required this.inverse,
    required this.onInverse,
    required this.inverseMuted,
    required this.inverseText,
    required this.inverseTrack,
    required this.inverseMonth,
    required this.toastIcon,
    this.scrim = const Color(0x731F1C17),
  });

  final Brightness brightness;
  final Color background;
  final Color surface;
  final Color sunken;
  final Color field;
  final Color navBar;
  final Color navIndicator;
  final Color ink;
  final Color ink2;
  final Color ink3;
  final Color muted;
  final Color border;
  final Color inputBorder;
  final Color softBorder;
  final Color strongBorder;
  final Color dot;
  final Color accent;
  final Color onAccent;
  final Color accentLight;
  final Color inverse;
  final Color onInverse;
  final Color inverseMuted;
  final Color inverseText;
  final Color inverseTrack;
  final Color inverseMonth;
  final Color toastIcon;
  final Color scrim;

  @override
  AppPalette copyWith() => this;

  @override
  AppPalette lerp(AppPalette? other, double t) => t < 0.5 || other == null ? this : other;
}

extension AppPaletteContext on BuildContext {
  AppPalette get palette => Theme.of(this).extension<AppPalette>()!;
}
