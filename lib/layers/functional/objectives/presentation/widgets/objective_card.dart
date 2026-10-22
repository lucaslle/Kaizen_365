import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';

import '../../../../technical/localization/app_locale.dart';
import '../../../../technical/localization/formatters.dart';
import '../../../../technical/theme/app_text.dart';
import '../../../../technical/theme/widgets/progress_track.dart';
import '../../domain/entities/objective.dart';
import '../../domain/entities/progress.dart';
import '../styles/domain_style.dart';
import '../styles/objective_texts.dart';
import '../styles/status_style.dart';
import 'domain_label.dart';
import '../../../../../layers/technical/theme/app_palette.dart';
import 'objective_status_pill.dart';

class ObjectiveCard extends StatelessWidget {
  const ObjectiveCard({super.key, required this.objective, required this.expected, required this.onTap});

  final Objective objective;
  final double expected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final progress = objectiveProgress(objective);
    final status = statusFor(progress, expected);
    final domain = DomainStyle.of(objective.domain);
    return Semantics(
      button: true,
      label: context.formatString(AppLocale.objectiveCardSemantics, [
        objective.title,
        domain.labelKey.getString(context),
        Formatters.percent(progress),
        StatusStyle.of(status).labelKey.getString(context),
      ]),
      excludeSemantics: true,
      child: Material(
        color: context.palette.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: BorderSide(color: context.palette.border),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 14,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(child: DomainLabel(domain: objective.domain)),
                    ObjectiveStatusPill(status: status),
                  ],
                ),
                Text(objective.title, style: context.text.cardTitle),
                ProgressTrack(value: progress, color: domain.color, expected: expected),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(context.keyResultCount(objective.keyResults.length), style: context.text.small),
                    Text(Formatters.percent(progress), style: context.text.mono(18, weight: 600)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
