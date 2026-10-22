import '../../domain/entities/key_result.dart';
import '../../domain/entities/life_domain.dart';
import '../../domain/entities/objective.dart';
import 'key_result_draft.dart';

export 'key_result_draft.dart';

enum WizardStep { what, why, how, recap }

const _keep = Object();

class ObjectiveWizardState {
  const ObjectiveWizardState({
    this.step = WizardStep.what,
    this.title = '',
    this.titleRevision = 0,
    this.domain = LifeDomain.health,
    this.why = '',
    this.keyResults = const [],
    this.draft = const KeyResultDraft(),
    this.draftRevision = 0,
    this.milestoneRevision = 0,
    this.editingObjective,
    this.editingKeyResult,
    this.savedObjectiveId,
    this.hasFailed = false,
  });

  factory ObjectiveWizardState.editing(Objective objective) => ObjectiveWizardState(
    title: objective.title,
    domain: objective.domain,
    why: objective.why,
    keyResults: objective.keyResults,
    editingObjective: objective,
  );

  final WizardStep step;
  final String title;
  final int titleRevision;
  final LifeDomain domain;
  final String why;
  final List<KeyResult> keyResults;
  final KeyResultDraft draft;
  final int draftRevision;
  final int milestoneRevision;
  final Objective? editingObjective;
  final KeyResult? editingKeyResult;
  final String? savedObjectiveId;
  final bool hasFailed;

  bool get isEditing => editingObjective != null;

  bool get canGoNext => switch (step) {
    WizardStep.what => title.trim().length > 2,
    WizardStep.how => keyResults.isNotEmpty && editingKeyResult == null,
    _ => true,
  };

  ObjectiveWizardState copyWith({
    WizardStep? step,
    String? title,
    int? titleRevision,
    LifeDomain? domain,
    String? why,
    List<KeyResult>? keyResults,
    KeyResultDraft? draft,
    int? draftRevision,
    int? milestoneRevision,
    Object? editingKeyResult = _keep,
    String? savedObjectiveId,
    bool? hasFailed,
  }) => ObjectiveWizardState(
    step: step ?? this.step,
    title: title ?? this.title,
    titleRevision: titleRevision ?? this.titleRevision,
    domain: domain ?? this.domain,
    why: why ?? this.why,
    keyResults: keyResults ?? this.keyResults,
    draft: draft ?? this.draft,
    draftRevision: draftRevision ?? this.draftRevision,
    milestoneRevision: milestoneRevision ?? this.milestoneRevision,
    editingObjective: editingObjective,
    editingKeyResult: identical(editingKeyResult, _keep) ? this.editingKeyResult : editingKeyResult as KeyResult?,
    savedObjectiveId: savedObjectiveId ?? this.savedObjectiveId,
    hasFailed: hasFailed ?? false,
  );
}
