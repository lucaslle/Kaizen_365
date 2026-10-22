import 'package:flutter/widgets.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../../technical/localization/app_locale.dart';
import '../../../../technical/theme/app_colors.dart';
import '../../domain/entities/objective_status.dart';

class StatusStyle {
  const StatusStyle(this.icon, this.labelKey, this.foreground, this.background);

  final IconData icon;
  final String labelKey;
  final Color foreground;
  final Color background;

  static StatusStyle of(ObjectiveStatus status) => switch (status) {
    ObjectiveStatus.done => const StatusStyle(
      Symbols.verified_rounded,
      AppLocale.statusDone,
      AppColors.brandCream,
      AppColors.brandInk,
    ),
    ObjectiveStatus.onTrack => const StatusStyle(
      Symbols.check_circle_rounded,
      AppLocale.statusOnTrack,
      AppColors.onTrackFg,
      AppColors.onTrackBg,
    ),
    ObjectiveStatus.atRisk => const StatusStyle(
      Symbols.warning_rounded,
      AppLocale.statusAtRisk,
      AppColors.atRiskFg,
      AppColors.atRiskBg,
    ),
    ObjectiveStatus.late => const StatusStyle(
      Symbols.schedule_rounded,
      AppLocale.statusLate,
      AppColors.lateFg,
      AppColors.lateBg,
    ),
  };
}
