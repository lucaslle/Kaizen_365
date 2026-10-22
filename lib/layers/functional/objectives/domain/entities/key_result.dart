import 'milestone.dart';

enum KeyResultType { numeric, percent, milestones }

class KeyResult {
  const KeyResult({
    required this.id,
    required this.title,
    required this.type,
    this.start = 0,
    this.value = 0,
    this.target = 0,
    this.unit = '',
    this.step = 1,
    this.milestones = const [],
  });

  final String id;
  final String title;
  final KeyResultType type;
  final double start;
  final double value;
  final double target;
  final String unit;
  final double step;
  final List<Milestone> milestones;

  int get doneCount => milestones.where((m) => m.isDone).length;

  KeyResult copyWith({String? id, double? value, List<Milestone>? milestones}) => KeyResult(
    id: id ?? this.id,
    title: title,
    type: type,
    start: start,
    value: value ?? this.value,
    target: target,
    unit: unit,
    step: step,
    milestones: milestones ?? this.milestones,
  );
}
