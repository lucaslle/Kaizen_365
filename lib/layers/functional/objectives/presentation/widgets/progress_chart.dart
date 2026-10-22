import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';

import '../../../../technical/localization/app_locale.dart';
import '../../../../technical/localization/formatters.dart';
import '../../../../technical/theme/app_palette.dart';
import '../../../../technical/theme/app_text.dart';
import '../../../../technical/theme/widgets/app_card.dart';
import '../../domain/entities/objective.dart';
import '../../domain/entities/progress.dart';
import '../../domain/entities/progress_history.dart';
import 'progress_chart_painter.dart';

class ProgressChart extends StatefulWidget {
  const ProgressChart({super.key, required this.objective, required this.now, required this.color});

  final Objective objective;
  final DateTime now;
  final Color color;

  @override
  State<ProgressChart> createState() => _ProgressChartState();
}

class _ProgressChartState extends State<ProgressChart> {
  ProgressPoint? _focused;

  @override
  Widget build(BuildContext context) {
    final year = widget.objective.year;
    final start = DateTime(year);
    final end = DateTime(year + 1);
    final points = [
      for (final p in progressHistory(widget.objective, widget.now))
        ProgressPoint(p.date.isBefore(start) ? start : (p.date.isAfter(end) ? end : p.date), p.progress),
    ];
    final palette = context.palette;
    final current = points.last.progress;
    final expected = expectedProgress(widget.now, year: year);
    final focused = _focused;
    return AppCard(
      radius: 20,
      padding: const EdgeInsets.fromLTRB(12, 14, 16, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 8,
        children: [
          SizedBox(
            height: 20,
            child: focused == null
                ? null
                : Text(
                    context.formatString(AppLocale.chartPoint, [
                      Formatters.shortDate(focused.date),
                      Formatters.percent(focused.progress),
                    ]),
                    style: context.text.mono(12, weight: 600),
                    textAlign: TextAlign.end,
                  ),
          ),
          Semantics(
            label: context.formatString(AppLocale.chartSemantics, [
              Formatters.percent(current),
              Formatters.percent(expected),
            ]),
            child: LayoutBuilder(
              builder: (context, constraints) {
                double xOf(DateTime d) =>
                    ProgressChartPainter.leftGutter +
                    (constraints.maxWidth - ProgressChartPainter.leftGutter) *
                        (d.difference(start).inHours / end.difference(start).inHours);
                void focusAt(double x) {
                  final nearest = points.reduce((a, b) => (xOf(a.date) - x).abs() <= (xOf(b.date) - x).abs() ? a : b);
                  setState(() => _focused = nearest);
                }

                return GestureDetector(
                  onTapDown: (d) => focusAt(d.localPosition.dx),
                  onHorizontalDragUpdate: (d) => focusAt(d.localPosition.dx),
                  onHorizontalDragEnd: (_) => setState(() => _focused = null),
                  child: CustomPaint(
                    size: Size(constraints.maxWidth, 150),
                    painter: ProgressChartPainter(
                      points: points,
                      start: start,
                      end: end,
                      now: widget.now,
                      focused: focused,
                      lineColor: widget.color,
                      expectedColor: palette.muted,
                      gridColor: palette.border,
                      surfaceColor: palette.surface,
                      labelStyle: context.text.mono(10, color: palette.muted),
                      expectedLabel: AppLocale.chartExpected.getString(context),
                      monthInitials: Formatters.monthInitials(year),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
