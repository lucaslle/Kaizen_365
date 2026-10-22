import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/key_result.dart';
import '../../domain/entities/life_domain.dart';
import '../../domain/entities/objective.dart';
import '../../domain/use_cases/create_objective_use_case.dart';
import '../../domain/use_cases/update_objective_use_case.dart';
import 'objective_wizard_state.dart';

class ObjectiveWizardCubit extends Cubit<ObjectiveWizardState> {
  ObjectiveWizardCubit(this._createObjective, this._updateObjective, {required this.year, Objective? editing})
    : super(editing == null ? const ObjectiveWizardState() : ObjectiveWizardState.editing(editing));

  final CreateObjectiveUseCase _createObjective;
  final UpdateObjectiveUseCase _updateObjective;
  final int year;

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
      final editing = state.editingObjective;
      final saved = editing == null
          ? await _createObjective(
              title: state.title,
              domain: state.domain,
              year: year,
              why: state.why,
              keyResults: state.keyResults,
            )
          : await _updateObjective(
              editing,
              title: state.title,
              domain: state.domain,
              why: state.why,
              keyResults: state.keyResults,
            );
      emit(state.copyWith(savedObjectiveId: saved.id));
    } catch (error, stackTrace) {
      debugPrint('Saving objective failed: $error\n$stackTrace');
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
    if (!state.draft.isValid) return;
    final previous = state.editingKeyResult;
    final keyResult = state.draft.toKeyResult(
      previous?.id ?? 'k${DateTime.now().microsecondsSinceEpoch}',
      previous: previous,
    );
    _resetDraft(
      previous == null
          ? [...state.keyResults, keyResult]
          : [for (final k in state.keyResults) k.id == previous.id ? keyResult : k],
    );
  }

  void editKeyResult(int index) {
    if (state.editingKeyResult != null) return;
    final keyResult = state.keyResults[index];
    emit(
      state.copyWith(
        draft: KeyResultDraft.fromKeyResult(keyResult),
        draftRevision: state.draftRevision + 1,
        editingKeyResult: keyResult,
      ),
    );
  }

  void cancelKeyResultEdit() => _resetDraft(state.keyResults);

  void removeKeyResult(int index) {
    if (state.editingKeyResult != null) return;
    emit(state.copyWith(keyResults: [...state.keyResults]..removeAt(index)));
  }

  void _resetDraft(List<KeyResult> keyResults) => emit(
    state.copyWith(
      keyResults: keyResults,
      draft: const KeyResultDraft(),
      draftRevision: state.draftRevision + 1,
      editingKeyResult: null,
    ),
  );
}
