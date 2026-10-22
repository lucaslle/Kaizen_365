import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';

import '../../../../technical/localization/app_locale.dart';
import '../../../../technical/localization/formatters.dart';
import '../../../../technical/theme/app_text.dart';
import '../../../../technical/theme/widgets/app_card.dart';
import '../../domain/entities/key_result.dart';
import '../../domain/entities/objective.dart';
import '../../../../../layers/technical/theme/app_palette.dart';
import '../../domain/entities/progress.dart';

class YearStats extends StatelessWidget {
  const YearStats({super.key, required this.objectives});

  final List<Objective> objectives;

  @override
  Widget build(BuildContext context) {
    final keyResults = objectives.expand((o) => o.keyResults).toList();
    final milestones = keyResults.where((k) => k.type == KeyResultType.milestones).expand((k) => k.milestones).toList();
    final stats = [
      (
        '${objectives.where((o) => objectiveProgress(o) >= 0.999).length}/${objectives.length}',
        AppLocale.statObjectives,
      ),
      ('${keyResults.where((k) => keyResultProgress(k) >= 1).length}/${keyResults.length}', AppLocale.statKeyResults),
      ('${milestones.where((m) => m.isDone).length}/${milestones.length}', AppLocale.statMilestones),
      ('${objectives.fold(0, (sum, o) => sum + o.checkins.length)}', AppLocale.statCheckins),
    ];
    return Column(
      spacing: 10,
      children: [
        AppCard(
          color: context.palette.accent,
          hasBorder: false,
          padding: const EdgeInsets.all(20),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 4,
                  children: [
                    Text(
                      AppLocale.yearScore.getString(context).toUpperCase(),
                      style: context.text.overline.copyWith(color: context.palette.onAccent),
                    ),
                    Text(
                      AppLocale.yearScoreBody.getString(context),
                      style: context.text.sans(15, color: context.palette.onAccent),
                    ),
                  ],
                ),
              ),
              Text(
                Formatters.percent(yearScore(objectives)),
                style: context.text.mono(52, weight: 600, height: 1, tracking: -0.04, color: context.palette.onAccent),
              ),
            ],
          ),
        ),
        for (var row = 0; row < 2; row++)
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 10,
              children: [
                for (final (value, label) in stats.skip(row * 2).take(2))
                  Expanded(
                    child: AppCard(
                      radius: 18,
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 6,
                        children: [
                          Text(value, style: context.text.mono(26, weight: 600, height: 1, tracking: -0.03)),
                          Text(
                            label.getString(context),
                            style: context.text.sans(14, height: 1.3, color: context.palette.muted),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}
