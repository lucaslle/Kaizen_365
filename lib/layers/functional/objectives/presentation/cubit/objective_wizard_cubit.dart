import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/key_result.dart';
import '../../domain/entities/life_domain.dart';
import '../../domain/entities/milestone.dart';
import '../../domain/use_cases/create_objective_use_case.dart';
import 'objective_wizard_state.dart';

class ObjectiveWizardCubit extends Cubit<ObjectiveWizardState> {
  ObjectiveWizardCubit(this._createObjective) : super(const ObjectiveWizardState());

  final CreateObjectiveUseCase _createObjective;

  void titleChanged(String title) => emit(state.copyWith(title: title));

  void suggestionPicked(String title) => emit(state.copyWith(title: title, titleRevision: state.titleRevision + 1));

  void domainSelected(LifeDomain domain) => emit(state.copyWith(domain: domain));

  void whyChanged(String why) => emit(state.copyWith(why: why));

  void back() => emit(state.copyWith(step: WizardStep.values[state.step.index - 1]));

  Future<void> next() async {
    if (!state.canGoNext) return;
    if (state.step != WizardStep.recap) {
      emit(state.copyWith(step: WizardStep.values[state.step.index + 1]));
      return;
    }
    try {
      final objective = await _createObjective(
        title: state.title,
        domain: state.domain,
        why: state.why,
        keyResults: state.keyResults,
      );
      emit(state.copyWith(createdObjectiveId: objective.id));
    } catch (error, stackTrace) {
      debugPrint('Objective creation failed: $error\n$stackTrace');
      emit(state.copyWith(hasFailed: true));
    }
  }

  void draftChanged(KeyResultDraft draft) => emit(state.copyWith(draft: draft));

  void addDraftMilestone() {
    final title = state.draft.milestoneInput.trim();
    if (title.isEmpty) return;
    emit(
      state.copyWith(
        draft: state.draft.copyWith(milestones: [...state.draft.milestones, title], milestoneInput: ''),
        milestoneRevision: state.milestoneRevision + 1,
      ),
    );
  }

  void removeDraftMilestone(int index) =>
      emit(state.copyWith(draft: state.draft.copyWith(milestones: [...state.draft.milestones]..removeAt(index))));

  void addKeyResult() {
    final draft = state.draft;
    if (!draft.isValid) return;
    final id = 'k${DateTime.now().microsecondsSinceEpoch}';
    final keyResult = switch (draft.type) {
      KeyResultType.numeric => KeyResult(
        id: id,
        title: draft.title.trim(),
        type: draft.type,
        start: draft.startValue,
        value: draft.startValue,
        target: draft.targetValue!,
        unit: draft.unit.trim(),
        step: draft.targetValue! >= 1000
            ? 100
            : draft.targetValue! >= 100
            ? 10
            : 1,
      ),
      KeyResultType.percent => KeyResult(id: id, title: draft.title.trim(), type: draft.type),
      KeyResultType.milestones => KeyResult(
        id: id,
        title: draft.title.trim(),
        type: draft.type,
        milestones: [for (final t in draft.milestones) Milestone(title: t)],
      ),
    };
    emit(
      state.copyWith(
        keyResults: [...state.keyResults, keyResult],
        draft: const KeyResultDraft(),
        draftRevision: state.draftRevision + 1,
      ),
    );
  }

  void removeKeyResult(int index) => emit(state.copyWith(keyResults: [...state.keyResults]..removeAt(index)));
}
