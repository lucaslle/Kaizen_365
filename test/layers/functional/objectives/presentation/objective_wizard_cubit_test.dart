import 'package:flutter_test/flutter_test.dart';
import 'package:kaizen365/layers/functional/objectives/domain/entities/key_result.dart';
import 'package:kaizen365/layers/functional/objectives/domain/use_cases/create_objective_use_case.dart';
import 'package:kaizen365/layers/functional/objectives/presentation/cubit/objective_wizard_cubit.dart';
import 'package:kaizen365/layers/functional/objectives/presentation/cubit/objective_wizard_state.dart';

import '../fake_objective_gateway.dart';

void main() {
  late FakeObjectiveGateway gateway;
  late ObjectiveWizardCubit cubit;

  setUp(() {
    gateway = FakeObjectiveGateway();
    cubit = ObjectiveWizardCubit(CreateObjectiveUseCase(gateway, () => DateTime(2026, 10, 13)));
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
    expect(cubit.state.createdObjectiveId, created.id);
    expect(created.title, 'Lire 24 livres');
    expect(created.checkins, hasLength(1));
  });
}
