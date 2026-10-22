import 'package:flutter/widgets.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../../technical/localization/app_locale.dart';
import '../../../../technical/theme/app_colors.dart';
import '../../domain/entities/mood.dart';

class MoodStyle {
  const MoodStyle(this.icon, this.labelKey, this.color);

  final IconData icon;
  final String labelKey;
  final Color color;

  static MoodStyle of(Mood mood) => switch (mood) {
    Mood.up => const MoodStyle(Symbols.sentiment_satisfied_rounded, AppLocale.moodUp, AppColors.moodUp),
    Mood.mid => const MoodStyle(Symbols.sentiment_neutral_rounded, AppLocale.moodMid, AppColors.moodMid),
    Mood.down => const MoodStyle(Symbols.sentiment_dissatisfied_rounded, AppLocale.moodDown, AppColors.moodDown),
  };
}
