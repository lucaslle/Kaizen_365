import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';

import '../../../../technical/localization/app_locale.dart';
import '../../../../technical/localization/formatters.dart';
import '../../../../technical/theme/app_text.dart';
import '../../../../technical/theme/widgets/app_card.dart';
import '../../../../technical/theme/widgets/progress_track.dart';
import '../../domain/entities/objective.dart';
import '../../domain/entities/progress.dart';
import '../styles/domain_style.dart';
import 'objective_status_pill.dart';

class ProgressHeroCard extends StatelessWidget {
  const ProgressHeroCard({super.key, required this.objective, required this.expected});

  final Objective objective;
  final double expected;

  @override
  Widget build(BuildContext context) {
    final progress = objectiveProgress(objective);
    final diff = ((progress - expected) * 100).round();
    return AppCard(
      radius: 24,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 14,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(Formatters.percent(progress), style: context.text.mono(56, weight: 600, height: 1, tracking: -0.05)),
              ObjectiveStatusPill(status: statusFor(progress, expected), height: 28),
            ],
          ),
          ProgressTrack(
            value: progress,
            color: DomainStyle.of(objective.domain).color,
            height: 12,
            expected: expected,
            semanticsLabel: AppLocale.objectiveProgressLabel.getString(context),
          ),
          Text(
            progress >= 0.999
                ? AppLocale.objectiveDone.getString(context)
                : context.formatString(AppLocale.expectedDiff, [
                    Formatters.percent(expected),
                    '${diff >= 0 ? '+' : ''}$diff',
                  ]),
            style: context.text.small,
          ),
        ],
      ),
    );
  }
}
