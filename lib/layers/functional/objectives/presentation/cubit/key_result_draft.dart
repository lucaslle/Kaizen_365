import '../../domain/entities/key_result.dart';
import '../../domain/entities/milestone.dart';

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

  factory KeyResultDraft.fromKeyResult(KeyResult k) => KeyResultDraft(
    title: k.title,
    type: k.type,
    start: _plain(k.start),
    target: k.type == KeyResultType.numeric ? _plain(k.target) : '',
    unit: k.unit,
    milestones: [for (final m in k.milestones) m.title],
  );

  /// Keeps the progress of [previous] when the type is unchanged: current value, and done flags matched by title.
  KeyResult toKeyResult(String id, {KeyResult? previous}) {
    final kept = previous?.type == type ? previous : null;
    final target = targetValue ?? 0;
    final doneTitles = {
      for (final m in kept?.milestones ?? const <Milestone>[])
        if (m.isDone) m.title,
    };
    return switch (type) {
      KeyResultType.numeric => KeyResult(
        id: id,
        title: title.trim(),
        type: type,
        start: startValue,
        value: kept?.value ?? startValue,
        target: target,
        unit: unit.trim(),
        step: target >= 1000
            ? 100
            : target >= 100
            ? 10
            : 1,
      ),
      KeyResultType.percent => KeyResult(id: id, title: title.trim(), type: type, value: kept?.value ?? 0),
      KeyResultType.milestones => KeyResult(
        id: id,
        title: title.trim(),
        type: type,
        milestones: [for (final t in milestones) Milestone(title: t, isDone: doneTitles.contains(t))],
      ),
    };
  }

  static String _plain(double v) => v == v.roundToDouble() ? v.round().toString() : v.toString();
}
