import 'package:flutter/material.dart';

import 'app_palette.dart';
import 'app_text.dart';

abstract final class AppTheme {
  static ThemeData of(AppPalette palette) {
    final text = AppText(palette);
    return ThemeData(
      brightness: palette.brightness,
      fontFamily: 'BricolageGrotesque',
      scaffoldBackgroundColor: palette.background,
      extensions: [palette],
      colorScheme: ColorScheme.fromSeed(
        seedColor: palette.accent,
        brightness: palette.brightness,
        primary: palette.accent,
        onPrimary: palette.onAccent,
        surface: palette.surface,
        onSurface: palette.ink,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: palette.background,
        surfaceTintColor: Colors.transparent,
        foregroundColor: palette.ink,
      ),
      iconTheme: IconThemeData(color: palette.ink),
      textSelectionTheme: TextSelectionThemeData(cursorColor: palette.accent),
      sliderTheme: SliderThemeData(
        activeTrackColor: palette.accent,
        thumbColor: palette.accent,
        inactiveTrackColor: palette.sunken,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: palette.inverse,
        contentTextStyle: text.sans(14, weight: 500, color: palette.onInverse),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }
}
