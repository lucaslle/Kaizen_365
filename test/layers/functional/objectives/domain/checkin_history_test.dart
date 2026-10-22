import 'package:flutter_test/flutter_test.dart';
import 'package:kaizen365/layers/functional/objectives/domain/entities/checkin.dart';
import 'package:kaizen365/layers/functional/objectives/domain/entities/checkin_revert.dart';
import 'package:kaizen365/layers/functional/objectives/domain/entities/key_result.dart';
import 'package:kaizen365/layers/functional/objectives/domain/entities/life_domain.dart';
import 'package:kaizen365/layers/functional/objectives/domain/entities/milestone.dart';
import 'package:kaizen365/layers/functional/objectives/domain/entities/objective.dart';
import 'package:kaizen365/layers/functional/objectives/domain/entities/objective_sort.dart';
import 'package:kaizen365/layers/functional/objectives/domain/entities/progress_change.dart';
import 'package:kaizen365/layers/functional/objectives/domain/entities/progress_history.dart';

Checkin _change(String id, DateTime date, ProgressChange change) => Checkin(id: id, date: date, change: change);

void main() {
  const km = KeyResult(id: 'km', title: 'Km', type: KeyResultType.numeric, value: 600, target: 1000, unit: 'km');
  const plan = KeyResult(
    id: 'plan',
    title: 'Plan',
    type: KeyResultType.milestones,
    milestones: [
      Milestone(title: 'A', isDone: true),
      Milestone(title: 'B'),
    ],
  );
  final objective = Objective(
    id: 'o',
    title: 'Courir',
    domain: LifeDomain.health,
    year: 2026,
    keyResults: const [km, plan],
    checkins: [
      _change(
        'c3',
        DateTime(2026, 6, 1),
        const ProgressChange(kind: ProgressChangeKind.value, subject: 'Km', from: 200, to: 600, keyResultId: 'km'),
      ),
      _change(
        'c2',
        DateTime(2026, 4, 1),
        const ProgressChange(kind: ProgressChangeKind.milestoneDone, subject: 'A', keyResultId: 'plan'),
      ),
      _change('c1', DateTime(2026, 1, 10), const ProgressChange(kind: ProgressChangeKind.created)),
    ],
  );

  group('deleting a check-in', () {
    test('reverts a value change when the key result still holds the value it set', () {
      final reverted = objective.withoutCheckin('c3');
      expect(reverted.keyResults.first.value, 200);
      expect([for (final c in reverted.checkins) c.id], ['c2', 'c1']);
    });

    test('keeps the current value when it changed since', () {
      final moved = objective.replacingKeyResult(km.copyWith(value: 700)).withoutCheckin('c3');
      expect(moved.keyResults.first.value, 700);
    });

    test('unchecks the milestone a milestone check-in validated', () {
      expect(objective.withoutCheckin('c2').keyResults.last.milestones.first.isDone, isFalse);
    });

    test('matches legacy changes by key result title', () {
      final legacy = objective.copyWith(
        checkins: [
          _change(
            'old',
            DateTime(2026, 6, 1),
            const ProgressChange(kind: ProgressChangeKind.value, subject: 'Km', from: 100, to: 600),
          ),
        ],
      );
      expect(legacy.withoutCheckin('old').keyResults.first.value, 100);
    });
  });

  test('progress history replays the changes backwards from today', () {
    final history = progressHistory(objective, DateTime(2026, 10, 13));
    expect(
      [for (final p in history) p.date],
      [DateTime(2026, 1, 10), DateTime(2026, 4, 1), DateTime(2026, 6, 1), DateTime(2026, 10, 13)],
    );
    expect([for (final p in history) p.progress], [0.1, 0.35, 0.55, 0.55]);
  });

  test('objectives sort by status gap or by progress, manual keeps the stored order', () {
    Objective withPercent(String id, double value) => Objective(
      id: id,
      title: id,
      domain: LifeDomain.health,
      year: 2026,
      keyResults: [KeyResult(id: id, title: id, type: KeyResultType.percent, value: value)],
    );
    final list = [withPercent('a', 50), withPercent('b', 90), withPercent('c', 10)];
    List<String> ids(List<Objective> l) => [for (final o in l) o.id];
    expect(ids(sortObjectives(list, ObjectiveSort.manual, 0.5)), ['a', 'b', 'c']);
    expect(ids(sortObjectives(list, ObjectiveSort.status, 0.5)), ['c', 'a', 'b']);
    expect(ids(sortObjectives(list, ObjectiveSort.progress, 0.5)), ['b', 'a', 'c']);
  });
}
