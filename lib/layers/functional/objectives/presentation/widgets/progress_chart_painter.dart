import 'package:flutter/rendering.dart';

import '../../domain/entities/progress_history.dart';

class ProgressChartPainter extends CustomPainter {
  const ProgressChartPainter({
    required this.points,
    required this.start,
    required this.end,
    required this.now,
    required this.focused,
    required this.lineColor,
    required this.expectedColor,
    required this.gridColor,
    required this.surfaceColor,
    required this.labelStyle,
    required this.expectedLabel,
    required this.monthInitials,
  });

  static const leftGutter = 30.0;
  static const _bottomGutter = 16.0;

  final List<ProgressPoint> points;
  final DateTime start;
  final DateTime end;
  final DateTime now;
  final ProgressPoint? focused;
  final Color lineColor;
  final Color expectedColor;
  final Color gridColor;
  final Color surfaceColor;
  final TextStyle labelStyle;
  final String expectedLabel;
  final List<String> monthInitials;

  @override
  void paint(Canvas canvas, Size size) {
    final plot = Rect.fromLTRB(leftGutter, 4, size.width, size.height - _bottomGutter);
    final span = end.difference(start).inHours;
    double x(DateTime d) => plot.left + plot.width * (d.difference(start).inHours / span).clamp(0.0, 1.0);
    double y(double p) => plot.bottom - plot.height * p.clamp(0.0, 1.0);

    final grid = Paint()
      ..color = gridColor
      ..strokeWidth = 1;
    for (final level in [0.0, 0.5, 1.0]) {
      canvas.drawLine(Offset(plot.left, y(level)), Offset(plot.right, y(level)), grid);
      _label(canvas, '${(level * 100).round()}%', Offset(0, y(level) - 6), leftGutter - 6, TextAlign.right);
    }
    for (var m = 0; m < 12; m += 3) {
      _label(canvas, monthInitials[m], Offset(x(DateTime(start.year, m + 1)), plot.bottom + 3), 14, TextAlign.left);
    }

    final expectedPaint = Paint()
      ..color = expectedColor
      ..strokeWidth = 1.5;
    final from = Offset(plot.left, plot.bottom);
    final to = Offset(plot.right, plot.top);
    const dashes = 40;
    for (var i = 0; i < dashes; i += 2) {
      canvas.drawLine(Offset.lerp(from, to, i / dashes)!, Offset.lerp(from, to, (i + 1) / dashes)!, expectedPaint);
    }
    _label(canvas, expectedLabel, Offset(plot.left + plot.width * 0.55 + 6, y(0.55) + 4), 70, TextAlign.left);

    final path = Path()..moveTo(x(points.first.date), y(points.first.progress));
    for (var i = 1; i < points.length; i++) {
      path
        ..lineTo(x(points[i].date), y(points[i - 1].progress))
        ..lineTo(x(points[i].date), y(points[i].progress));
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = lineColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeJoin = StrokeJoin.round,
    );
    final last = points.last;
    _dot(canvas, Offset(x(last.date), y(last.progress)), 4);

    final point = focused;
    if (point != null) {
      final at = Offset(x(point.date), y(point.progress));
      canvas.drawLine(Offset(at.dx, plot.top), Offset(at.dx, plot.bottom), grid..strokeWidth = 1.5);
      _dot(canvas, at, 5);
    }
  }

  void _dot(Canvas canvas, Offset center, double radius) {
    canvas
      ..drawCircle(center, radius + 2, Paint()..color = surfaceColor)
      ..drawCircle(center, radius, Paint()..color = lineColor);
  }

  void _label(Canvas canvas, String text, Offset at, double width, TextAlign align) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: labelStyle),
      textAlign: align,
      textDirection: TextDirection.ltr,
    )..layout(minWidth: width, maxWidth: width);
    painter.paint(canvas, at);
  }

  @override
  bool shouldRepaint(ProgressChartPainter oldDelegate) =>
      oldDelegate.points != points || oldDelegate.focused != focused || oldDelegate.lineColor != lineColor;
}
