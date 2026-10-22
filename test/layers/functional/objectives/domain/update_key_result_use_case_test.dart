import 'package:flutter_test/flutter_test.dart';
import 'package:kaizen365/layers/functional/objectives/domain/entities/key_result.dart';
import 'package:kaizen365/layers/functional/objectives/domain/entities/life_domain.dart';
import 'package:kaizen365/layers/functional/objectives/domain/entities/milestone.dart';
import 'package:kaizen365/layers/functional/objectives/domain/entities/objective.dart';
import 'package:kaizen365/layers/functional/objectives/domain/entities/progress_change.dart';
import 'package:kaizen365/layers/functional/objectives/domain/use_cases/toggle_milestone_use_case.dart';
import 'package:kaizen365/layers/functional/objectives/domain/use_cases/update_key_result_use_case.dart';

import '../fake_objective_gateway.dart';

void main() {
  const km = KeyResult(id: 'k1', title: 'Kilomètres', type: KeyResultType.numeric, value: 590, target: 900, unit: 'km');
  const plan = KeyResult(
    id: 'k2',
    title: 'Plan',
    type: KeyResultType.milestones,
    milestones: [
      Milestone(title: '10 km'),
      Milestone(title: 'Semi', isDone: true),
    ],
  );
  const objective = Objective(id: 'o1', title: 'Semi', domain: LifeDomain.health, keyResults: [km, plan]);
  late FakeObjectiveGateway gateway;
  DateTime clock() => DateTime(2026, 10, 13);

  setUp(() => gateway = FakeObjectiveGateway());

  test('numeric change records an automatic check-in', () async {
    final hasCheckin = await UpdateKeyResultUseCase(gateway, clock)(objective, km, value: 610);
    final saved = gateway.saved.single;
    expect(hasCheckin, isTrue);
    expect(saved.keyResults.first.value, 610);
    final change = saved.checkins.single.change!;
    expect(
      (change.kind, change.subject, change.from, change.to, change.unit),
      (ProgressChangeKind.value, 'Kilomètres', 590, 610, 'km'),
    );
  });

  test('numeric value is clamped between start and twice the target', () async {
    await UpdateKeyResultUseCase(gateway, clock)(objective, km, value: 5000);
    expect(gateway.saved.single.keyResults.first.value, 1800);
  });

  test('unchanged value without note records no check-in', () async {
    final hasCheckin = await UpdateKeyResultUseCase(gateway, clock)(objective, km, value: 590);
    expect(hasCheckin, isFalse);
    expect(gateway.saved.single.checkins, isEmpty);
  });

  test('a note alone records a check-in without change', () async {
    await UpdateKeyResultUseCase(gateway, clock)(objective, km, value: 590, note: '  Genou  ');
    final checkin = gateway.saved.single.checkins.single;
    expect((checkin.text, checkin.change), ('Genou', null));
  });

  test('validating a milestone logs it, unchecking does not', () async {
    final toggle = ToggleMilestoneUseCase(gateway, clock);
    expect(await toggle(objective, plan, 0), isTrue);
    expect(gateway.saved.last.checkins.single.change!.subject, '10 km');
    expect(await toggle(objective, plan, 1), isFalse);
    expect(gateway.saved.last.checkins, isEmpty);
    expect(gateway.saved.last.keyResults.last.milestones[1].isDone, isFalse);
  });
}
