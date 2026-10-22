import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../../technical/localization/app_locale.dart';
import '../../../../technical/localization/formatters.dart';
import '../../../../technical/theme/app_text.dart';
import '../../../../technical/theme/widgets/app_button.dart';
import '../../../../technical/theme/widgets/app_card.dart';
import '../../../../technical/theme/widgets/progress_track.dart';
import '../../domain/entities/key_result.dart';
import '../../domain/entities/progress.dart';
import '../styles/objective_texts.dart';
import 'milestone_row.dart';

class KeyResultCard extends StatelessWidget {
  const KeyResultCard({
    super.key,
    required this.keyResult,
    required this.color,
    required this.onUpdate,
    required this.onToggleMilestone,
  });

  final KeyResult keyResult;
  final Color color;
  final VoidCallback onUpdate;
  final ValueChanged<int> onToggleMilestone;

  @override
  Widget build(BuildContext context) {
    final progress = keyResultProgress(keyResult);
    return AppCard(
      radius: 20,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 12,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 12,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 3,
                  children: [
                    Text(context.typeLabel(keyResult.type).toUpperCase(), style: context.text.overline),
                    Text(keyResult.title, style: context.text.sans(17, weight: 600, height: 1.2)),
                  ],
                ),
              ),
              Text(Formatters.percent(progress), style: context.text.mono(16, weight: 600)),
            ],
          ),
          ProgressTrack(value: progress, color: color, height: 8, semanticsLabel: keyResult.title),
          if (keyResult.type == KeyResultType.milestones)
            Column(
              children: [
                for (final (i, m) in keyResult.milestones.indexed)
                  MilestoneRow(milestone: m, onToggle: () => onToggleMilestone(i)),
              ],
            ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(child: Text(context.keyResultValue(keyResult), style: context.text.small)),
              AppButton(
                label: AppLocale.update.getString(context),
                onPressed: onUpdate,
                variant: AppButtonVariant.outline,
                icon: Symbols.edit_rounded,
                height: 44,
                fontSize: 14,
                padding: 16,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
