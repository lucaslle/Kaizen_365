import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_text.dart';

abstract final class AppTheme {
  static ThemeData get light => ThemeData(
        fontFamily: 'BricolageGrotesque',
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.accent,
          primary: AppColors.accent,
          onPrimary: AppColors.onAccent,
          surface: AppColors.surface,
          onSurface: AppColors.ink,
        ),
        textSelectionTheme: const TextSelectionThemeData(cursorColor: AppColors.accent),
        sliderTheme: const SliderThemeData(
          activeTrackColor: AppColors.accent,
          thumbColor: AppColors.accent,
          inactiveTrackColor: AppColors.sunken,
        ),
        snackBarTheme: SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.ink,
          contentTextStyle: AppText.sans(14, weight: 500, color: AppColors.onAccent),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      );
}
