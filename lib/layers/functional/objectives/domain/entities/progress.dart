import 'key_result.dart';
import 'objective.dart';
import 'objective_status.dart';

int dayOfYear(DateTime now) => DateTime.utc(now.year, now.month, now.day).difference(DateTime.utc(now.year)).inDays + 1;

int daysInYear(int year) => DateTime.utc(year + 1).difference(DateTime.utc(year)).inDays;

/// Share of [year] already elapsed on [now]: 0 before it starts, 1 once it is over.
double expectedProgress(DateTime now, {int? year}) => switch ((year ?? now.year).compareTo(now.year)) {
  < 0 => 1,
  > 0 => 0,
  _ => dayOfYear(now) / daysInYear(now.year),
};

/// Day of [year] reached on [now], clamped to the year bounds.
int elapsedDays(int year, DateTime now) => switch (year.compareTo(now.year)) {
  < 0 => daysInYear(year),
  > 0 => 0,
  _ => dayOfYear(now),
};

double keyResultProgress(KeyResult k) {
  final raw = switch (k.type) {
    KeyResultType.percent => k.value / 100,
    KeyResultType.numeric => k.target == k.start ? 0.0 : (k.value - k.start) / (k.target - k.start),
    KeyResultType.milestones => k.milestones.isEmpty ? 0.0 : k.doneCount / k.milestones.length,
  };
  return raw.clamp(0.0, 1.0);
}

double objectiveProgress(Objective o) =>
    o.keyResults.isEmpty ? 0 : o.keyResults.map(keyResultProgress).reduce((a, b) => a + b) / o.keyResults.length;

double yearScore(List<Objective> objectives) =>
    objectives.isEmpty ? 0 : objectives.map(objectiveProgress).reduce((a, b) => a + b) / objectives.length;

ObjectiveStatus statusFor(double progress, double expected) {
  if (progress >= 0.999) return ObjectiveStatus.done;
  if (progress - expected >= -0.08) return ObjectiveStatus.onTrack;
  if (progress - expected >= -0.20) return ObjectiveStatus.atRisk;
  return ObjectiveStatus.late;
}
