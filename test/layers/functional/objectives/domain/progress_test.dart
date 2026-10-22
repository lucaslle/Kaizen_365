import 'package:flutter_test/flutter_test.dart';
import 'package:kaizen365/layers/functional/objectives/domain/entities/key_result.dart';
import 'package:kaizen365/layers/functional/objectives/domain/entities/life_domain.dart';
import 'package:kaizen365/layers/functional/objectives/domain/entities/milestone.dart';
import 'package:kaizen365/layers/functional/objectives/domain/entities/objective.dart';
import 'package:kaizen365/layers/functional/objectives/domain/entities/objective_status.dart';
import 'package:kaizen365/layers/functional/objectives/domain/entities/progress.dart';

void main() {
  const numeric = KeyResult(id: 'k1', title: 'Km', type: KeyResultType.numeric, start: 0, value: 640, target: 900);

  group('keyResultProgress', () {
    test('numeric is relative to start and target', () {
      expect(keyResultProgress(numeric), closeTo(640 / 900, 1e-9));
      expect(keyResultProgress(numeric.copyWith(value: 2000)), 1);
    });

    test('numeric with equal start and target is zero', () {
      expect(keyResultProgress(const KeyResult(id: 'k', title: 't', type: KeyResultType.numeric, target: 0)), 0);
    });

    test('numeric works with a decreasing target', () {
      const weight = KeyResult(id: 'k', title: 'kg', type: KeyResultType.numeric, start: 80, value: 75, target: 70);
      expect(keyResultProgress(weight), 0.5);
    });

    test('percent and milestones', () {
      expect(keyResultProgress(const KeyResult(id: 'k', title: 't', type: KeyResultType.percent, value: 70)), 0.7);
      const ms = KeyResult(id: 'k', title: 't', type: KeyResultType.milestones, milestones: [
        Milestone(title: 'a', isDone: true),
        Milestone(title: 'b'),
        Milestone(title: 'c', isDone: true),
        Milestone(title: 'd'),
      ]);
      expect(keyResultProgress(ms), 0.5);
      expect(keyResultProgress(const KeyResult(id: 'k', title: 't', type: KeyResultType.milestones)), 0);
    });
  });

  test('objective progress is the mean of its key results, year score the mean of objectives', () {
    const a = Objective(id: 'a', title: 'a', domain: LifeDomain.health, keyResults: [
      KeyResult(id: '1', title: 't', type: KeyResultType.percent, value: 100),
      KeyResult(id: '2', title: 't', type: KeyResultType.percent, value: 0),
    ]);
    const b = Objective(id: 'b', title: 'b', domain: LifeDomain.health);
    expect(objectiveProgress(a), 0.5);
    expect(objectiveProgress(b), 0);
    expect(yearScore([a, b]), 0.25);
    expect(yearScore([]), 0);
  });

  test('statusFor applies the thresholds against expected progress', () {
    const e = 0.78;
    expect(statusFor(1, e), ObjectiveStatus.done);
    expect(statusFor(0.71, e), ObjectiveStatus.onTrack);
    expect(statusFor(0.69, e), ObjectiveStatus.atRisk);
    expect(statusFor(0.59, e), ObjectiveStatus.atRisk);
    expect(statusFor(0.57, e), ObjectiveStatus.late);
  });

  test('expectedProgress uses day of year over days in year', () {
    expect(expectedProgress(DateTime(2026, 10, 13)), 286 / 365);
    expect(expectedProgress(DateTime(2028, 12, 31)), 1);
    expect(daysInYear(2028), 366);
  });
}
