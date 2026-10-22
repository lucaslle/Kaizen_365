import '../../domain/entities/key_result.dart';
import '../../domain/entities/life_domain.dart';

class KeyResultDraft {
  const KeyResultDraft({
    this.title = '',
    this.type = KeyResultType.numeric,
    this.start = '0',
    this.target = '',
    this.unit = '',
    this.milestones = const [],
    this.milestoneInput = '',
  });

  final String title;
  final KeyResultType type;
  final String start;
  final String target;
  final String unit;
  final List<String> milestones;
  final String milestoneInput;

  double get startValue => _parse(start) ?? 0;
  double? get targetValue => _parse(target);

  bool get isValid =>
      title.trim().isNotEmpty &&
      switch (type) {
        KeyResultType.numeric => targetValue != null && targetValue != startValue,
        KeyResultType.milestones => milestones.isNotEmpty,
        KeyResultType.percent => true,
      };

  static double? _parse(String text) => double.tryParse(text.trim().replaceAll(',', '.'));

  KeyResultDraft copyWith({
    String? title,
    KeyResultType? type,
    String? start,
    String? target,
    String? unit,
    List<String>? milestones,
    String? milestoneInput,
  }) => KeyResultDraft(
    title: title ?? this.title,
    type: type ?? this.type,
    start: start ?? this.start,
    target: target ?? this.target,
    unit: unit ?? this.unit,
    milestones: milestones ?? this.milestones,
    milestoneInput: milestoneInput ?? this.milestoneInput,
  );
}

enum WizardStep { what, why, how, recap }

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
    this.createdObjectiveId,
    this.hasFailed = false,
  });

  final WizardStep step;
  final String title;
  final int titleRevision;
  final LifeDomain domain;
  final String why;
  final List<KeyResult> keyResults;
  final KeyResultDraft draft;
  final int draftRevision;
  final int milestoneRevision;
  final String? createdObjectiveId;
  final bool hasFailed;

  bool get canGoNext => switch (step) {
    WizardStep.what => title.trim().length > 2,
    WizardStep.how => keyResults.isNotEmpty,
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
    String? createdObjectiveId,
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
    createdObjectiveId: createdObjectiveId ?? this.createdObjectiveId,
    hasFailed: hasFailed ?? false,
  );
}
