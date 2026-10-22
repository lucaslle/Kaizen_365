import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../../technical/localization/app_locale.dart';
import '../../../../technical/theme/app_colors.dart';
import '../../../../technical/theme/app_palette.dart';
import '../../../../technical/theme/app_text.dart';
import '../../../../technical/theme/widgets/app_button.dart';
import '../../../../technical/theme/widgets/confetti.dart';

class AchievementDialog extends StatelessWidget {
  const AchievementDialog({super.key, required this.title});

  final String title;

  static Future<void> show(BuildContext context, String title) => showDialog<void>(
    context: context,
    barrierColor: context.palette.scrim,
    builder: (_) => AchievementDialog(title: title),
  );

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Stack(
      children: [
        Positioned.fill(
          child: Confetti(
            colors: [palette.accent, palette.accentLight, AppColors.health, AppColors.learning, AppColors.finances],
          ),
        ),
        Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Material(
              color: palette.surface,
              borderRadius: BorderRadius.circular(28),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  spacing: 14,
                  children: [
                    CircleAvatar(
                      radius: 36,
                      backgroundColor: palette.inverse,
                      child: Icon(Symbols.verified_rounded, fill: 1, size: 40, color: palette.onInverse),
                    ),
                    Text(
                      AppLocale.achievedTitle.getString(context),
                      style: context.text.stepTitle,
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      context.formatString(AppLocale.achievedBody, [title]),
                      style: context.text.bodyMuted,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    SizedBox(
                      width: double.infinity,
                      child: AppButton(
                        label: AppLocale.achievedCta.getString(context),
                        onPressed: () => Navigator.of(context).pop(),
                        height: 52,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
