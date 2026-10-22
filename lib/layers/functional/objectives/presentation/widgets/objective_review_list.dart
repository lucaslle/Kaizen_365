import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localization/flutter_localization.dart';

import '../../../../technical/localization/app_locale.dart';
import '../../../../technical/localization/formatters.dart';
import '../../../../technical/theme/app_text.dart';
import '../../../../technical/theme/widgets/app_card.dart';
import '../../../../technical/theme/widgets/status_pill.dart';
import '../../domain/entities/objective.dart';
import '../../domain/entities/progress.dart';
import '../styles/domain_style.dart';
import '../styles/status_style.dart';
import '../../../../technical/theme/app_palette.dart';
import '../cubit/year_review_cubit.dart';

class ObjectiveReviewList extends StatelessWidget {
  const ObjectiveReviewList({
    super.key,
    required this.objectives,
    required this.carried,
    required this.now,
    required this.year,
    this.isEditable = true,
  });

  final List<Objective> objectives;
  final Set<String> carried;
  final DateTime now;
  final int year;
  final bool isEditable;

  @override
  Widget build(BuildContext context) {
    final expected = expectedProgress(now, year: year);
    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          for (final (i, o) in objectives.indexed)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: i == 0 ? Colors.transparent : context.palette.border)),
              ),
              child: _row(context, o, expected),
            ),
        ],
      ),
    );
  }

  Widget _row(BuildContext context, Objective objective, double expected) {
    final progress = objectiveProgress(objective);
    final status = StatusStyle.of(statusFor(progress, expected));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 10,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 12,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 6,
                children: [
                  Text(objective.title, style: context.text.sans(16, weight: 600, height: 1.2)),
                  StatusPill(
                    icon: status.icon,
                    label: status.labelKey.getString(context),
                    foreground: status.foreground,
                    background: status.background,
                    height: 24,
                  ),
                ],
              ),
            ),
            Text(
              Formatters.percent(progress),
              style: context.text.mono(
                20,
                weight: 600,
                color: DomainStyle.of(objective.domain).textColor(context.palette.brightness),
              ),
            ),
          ],
        ),
        if (progress < 0.999 && isEditable)
          MergeSemantics(
            child: Row(
              children: [
                Expanded(
                  child: Text(context.formatString(AppLocale.carryOver, [year + 1]), style: context.text.sans(14)),
                ),
                Switch(
                  value: carried.contains(objective.id),
                  onChanged: (_) => context.read<YearReviewCubit>().carryToggled(objective.id),
                  activeTrackColor: context.palette.accent,
                  inactiveTrackColor: context.palette.strongBorder,
                  inactiveThumbColor: context.palette.surface,
                  thumbColor: WidgetStatePropertyAll(context.palette.surface),
                  trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
