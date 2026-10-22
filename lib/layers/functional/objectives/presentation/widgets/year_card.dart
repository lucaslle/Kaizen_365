import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';

import '../../../../technical/localization/app_locale.dart';
import '../../../../technical/localization/formatters.dart';
import '../../../../technical/theme/app_text.dart';
import '../../../../technical/theme/widgets/app_card.dart';
import '../../../../technical/theme/app_palette.dart';
import '../../domain/entities/progress.dart';

class YearCard extends StatelessWidget {
  const YearCard({super.key, required this.now, required this.score, required this.expected});

  final DateTime now;
  final double score;
  final double expected;

  @override
  Widget build(BuildContext context) {
    final day = dayOfYear(now);
    final remaining = daysInYear(now.year) - day;
    final currentMonth = now.month - 1;
    final initials = Formatters.monthInitials(now.year);
    return AppCard(
      color: context.palette.inverse,
      hasBorder: false,
      radius: 24,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 16,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                context.formatString(AppLocale.yearLabel, [now.year]).toUpperCase(),
                style: context.text.overline.copyWith(color: context.palette.inverseMuted),
              ),
              Text(
                context.formatString(AppLocale.dayCounter, [day, remaining]),
                style: context.text.mono(12, weight: 400, color: context.palette.inverseMuted),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: _Stat(
                  Formatters.percent(score),
                  AppLocale.yourProgress.getString(context),
                  context.palette.accentLight,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _Stat(
                  Formatters.percent(expected),
                  AppLocale.timeElapsed.getString(context),
                  context.palette.onInverse,
                ),
              ),
            ],
          ),
          Semantics(
            label: context.formatString(AppLocale.yearSemantics, [
              Formatters.percent(expected),
              Formatters.monthName(now),
            ]),
            child: ExcludeSemantics(
              child: Row(
                spacing: 3,
                children: [
                  for (var m = 0; m < 12; m++)
                    Expanded(
                      child: Column(
                        spacing: 6,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: (expected * 12 - m).clamp(0, 1),
                              minHeight: 8,
                              color: context.palette.onInverse,
                              backgroundColor: context.palette.inverseTrack,
                            ),
                          ),
                          Text(
                            initials[m],
                            style: context.text.mono(
                              11,
                              color: m == currentMonth ? context.palette.accentLight : context.palette.inverseMonth,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat(this.value, this.label, this.color);

  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    spacing: 2,
    children: [
      Text(value, style: context.text.mono(44, weight: 600, height: 1, tracking: -0.04, color: color)),
      Text(label, style: context.text.sans(14, color: context.palette.inverseText)),
    ],
  );
}
