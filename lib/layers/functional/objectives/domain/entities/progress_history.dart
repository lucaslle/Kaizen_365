import 'checkin_revert.dart';
import 'key_result.dart';
import 'objective.dart';
import 'progress.dart';
import 'progress_change.dart';

class ProgressPoint {
  const ProgressPoint(this.date, this.progress);

  final DateTime date;
  final double progress;
}

/// Objective progress after each check-in, oldest first, rebuilt by undoing the recorded changes from today backwards.
List<ProgressPoint> progressHistory(Objective objective, DateTime now) {
  final progressById = {for (final k in objective.keyResults) k.id: keyResultProgress(k)};
  double mean() => progressById.isEmpty ? 0 : progressById.values.reduce((a, b) => a + b) / progressById.length;
  final points = [ProgressPoint(now, mean())];
  final checkins = [...objective.checkins]..sort((a, b) => b.date.compareTo(a.date));
  for (final checkin in checkins) {
    points.add(ProgressPoint(checkin.date, mean()));
    final change = checkin.change;
    final keyResult = change == null ? null : objective.keyResultOf(change);
    if (change == null || keyResult == null) continue;
    final before = _progressBefore(change, keyResult, progressById[keyResult.id]!);
    if (before != null) progressById[keyResult.id] = before;
  }
  return points.reversed.toList();
}

double? _progressBefore(ProgressChange change, KeyResult keyResult, double current) => switch (change.kind) {
  ProgressChangeKind.value => keyResultProgress(keyResult.copyWith(value: change.from)),
  ProgressChangeKind.percent => (change.from / 100).clamp(0.0, 1.0),
  ProgressChangeKind.milestones => change.total == 0 ? 0 : (change.from / change.total).clamp(0.0, 1.0),
  ProgressChangeKind.milestoneDone =>
    keyResult.milestones.isEmpty ? 0 : (current - 1 / keyResult.milestones.length).clamp(0.0, 1.0),
  _ => null,
};
