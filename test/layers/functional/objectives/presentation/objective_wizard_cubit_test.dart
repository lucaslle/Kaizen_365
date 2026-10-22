import 'package:flutter_test/flutter_test.dart';
import 'package:kaizen365/layers/functional/objectives/domain/entities/checkin.dart';
import 'package:kaizen365/layers/functional/objectives/domain/entities/key_result.dart';
import 'package:kaizen365/layers/functional/objectives/domain/entities/life_domain.dart';
import 'package:kaizen365/layers/functional/objectives/domain/entities/milestone.dart';
import 'package:kaizen365/layers/functional/objectives/domain/entities/objective.dart';
import 'package:kaizen365/layers/functional/objectives/domain/use_cases/create_objective_use_case.dart';
import 'package:kaizen365/layers/functional/objectives/domain/use_cases/update_objective_use_case.dart';
import 'package:kaizen365/layers/functional/objectives/presentation/cubit/objective_wizard_cubit.dart';
import 'package:kaizen365/layers/functional/objectives/presentation/cubit/objective_wizard_state.dart';

import '../fake_objective_gateway.dart';

void main() {
  late FakeObjectiveGateway gateway;
  late ObjectiveWizardCubit cubit;

  setUp(() {
    gateway = FakeObjectiveGateway();
    cubit = ObjectiveWizardCubit(
      CreateObjectiveUseCase(gateway, () => DateTime(2026, 10, 13)),
      UpdateObjectiveUseCase(gateway),
      year: 2026,
    );
  });

  tearDown(() => cubit.close());

  test('draft validation follows the key result type rules', () {
    expect(const KeyResultDraft(title: 'Km', target: '900').isValid, isTrue);
    expect(const KeyResultDraft(title: 'Km', target: '0').isValid, isFalse);
    expect(const KeyResultDraft(title: 'Km').isValid, isFalse);
    expect(const KeyResultDraft(title: ' ', target: '9').isValid, isFalse);
    expect(const KeyResultDraft(title: 'P', type: KeyResultType.percent).isValid, isTrue);
    expect(const KeyResultDraft(title: 'J', type: KeyResultType.milestones).isValid, isFalse);
    expect(const KeyResultDraft(title: 'J', type: KeyResultType.milestones, milestones: ['a']).isValid, isTrue);
  });

  test('the full flow creates an objective with its creation check-in', () async {
    cubit.titleChanged('Ab');
    await cubit.next();
    expect(cubit.state.step, WizardStep.what);
    cubit.titleChanged('Lire 24 livres');
    await cubit.next();
    await cubit.next();
    expect(cubit.state.step, WizardStep.how);
    await cubit.next();
    expect(cubit.state.step, WizardStep.how);
    cubit.draftChanged(const KeyResultDraft(title: 'Livres', target: '1500', unit: 'livres'));
    cubit.addKeyResult();
    expect(cubit.state.keyResults.single.step, 100);
    expect(cubit.state.draft.title, isEmpty);
    await cubit.next();
    await cubit.next();
    final created = gateway.saved.single;
    expect(cubit.state.savedObjectiveId, created.id);
    expect(created.title, 'Lire 24 livres');
    expect(created.checkins, hasLength(1));
    expect(created.year, 2026);
  });

  group('editing', () {
    const km = KeyResult(id: 'k1', title: 'Km', type: KeyResultType.numeric, value: 640, target: 900, unit: 'km');
    const plan = KeyResult(
      id: 'k2',
      title: 'Plan',
      type: KeyResultType.milestones,
      milestones: [
        Milestone(title: '10 km', isDone: true),
        Milestone(title: 'Semi'),
      ],
    );
    final objective = Objective(
      id: 'o1',
      title: 'Semi',
      domain: LifeDomain.health,
      year: 2026,
      keyResults: const [km, plan],
      checkins: [Checkin(id: 'c1', date: DateTime(2026, 10, 1), text: 'Go')],
    );

    test('a draft rebuilt from a key result keeps its progress', () {
      final draft = KeyResultDraft.fromKeyResult(km);
      expect((draft.title, draft.start, draft.target, draft.unit), ('Km', '0', '900', 'km'));
      final retargeted = draft.copyWith(target: '1000').toKeyResult('k1', previous: km);
      expect((retargeted.value, retargeted.target, retargeted.step), (640, 1000, 100));
      final milestones = KeyResultDraft.fromKeyResult(plan).copyWith(milestones: ['10 km', 'Semi', 'Marathon']);
      expect([for (final m in milestones.toKeyResult('k2', previous: plan).milestones) m.isDone], [true, false, false]);
      final retyped = draft.copyWith(type: KeyResultType.percent).toKeyResult('k1', previous: km);
      expect(retyped.value, 0);
    });

    test('saving an edit keeps id, order, progress and check-ins', () async {
      final editCubit = ObjectiveWizardCubit(
        CreateObjectiveUseCase(gateway, () => DateTime(2026, 10, 13)),
        UpdateObjectiveUseCase(gateway),
        year: 2026,
        editing: objective,
      );
      addTearDown(editCubit.close);
      expect(editCubit.state.title, 'Semi');
      editCubit.titleChanged('Courir le semi de Lyon');
      await editCubit.next();
      await editCubit.next();
      expect(editCubit.state.step, WizardStep.how);
      editCubit.editKeyResult(0);
      expect(editCubit.state.canGoNext, isFalse);
      editCubit.draftChanged(editCubit.state.draft.copyWith(target: '1000'));
      editCubit.addKeyResult();
      await editCubit.next();
      await editCubit.next();
      final saved = gateway.saved.single;
      expect(editCubit.state.savedObjectiveId, 'o1');
      expect(saved.id, 'o1');
      expect(saved.title, 'Courir le semi de Lyon');
      expect([for (final k in saved.keyResults) k.id], ['k1', 'k2']);
      expect((saved.keyResults.first.value, saved.keyResults.first.target), (640, 1000));
      expect(saved.checkins.single.text, 'Go');
    });

    test('cancelling a key result edit restores it untouched', () {
      final editCubit = ObjectiveWizardCubit(
        CreateObjectiveUseCase(gateway, () => DateTime(2026, 10, 13)),
        UpdateObjectiveUseCase(gateway),
        year: 2026,
        editing: objective,
      );
      addTearDown(editCubit.close);
      editCubit.editKeyResult(1);
      editCubit.draftChanged(editCubit.state.draft.copyWith(title: 'Autre'));
      editCubit.cancelKeyResultEdit();
      expect(editCubit.state.keyResults, objective.keyResults);
      expect(editCubit.state.editingKeyResult, isNull);
    });
  });
}
