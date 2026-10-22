import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';

import '../../../../technical/theme/widgets/status_pill.dart';
import '../../domain/entities/objective.dart';
import '../../domain/entities/objective_status.dart';
import '../../domain/entities/progress.dart';
import '../styles/status_style.dart';

class StatusSummary extends StatelessWidget {
  const StatusSummary({super.key, required this.objectives, required this.expected});

  final List<Objective> objectives;
  final double expected;

  @override
  Widget build(BuildContext context) {
    final counts = {for (final s in ObjectiveStatus.values) s: 0};
    for (final o in objectives) {
      final status = statusFor(objectiveProgress(o), expected);
      counts[status] = counts[status]! + 1;
    }
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final status in ObjectiveStatus.values)
          if (counts[status]! > 0)
            StatusPill(
              icon: StatusStyle.of(status).icon,
              label: '${counts[status]} ${StatusStyle.of(status).labelKey.getString(context).toLowerCase()}',
              foreground: StatusStyle.of(status).foreground,
              background: StatusStyle.of(status).background,
              height: 32,
              fontSize: 14,
              fontWeight: 500,
            ),
      ],
    );
  }
}
