import 'dart:math';

import '../../../../technical/clock/clock.dart';
import '../entities/checkin.dart';
import '../entities/key_result.dart';
import '../entities/milestone.dart';
import '../entities/objective.dart';
import '../entities/progress_change.dart';
import '../gateways/objective_gateway.dart';

class UpdateKeyResultUseCase {
  UpdateKeyResultUseCase(this._gateway, this._clock);

  final ObjectiveGateway _gateway;
  final Clock _clock;

  /// Returns true when a check-in was recorded.
  Future<bool> call(
    Objective objective,
    KeyResult keyResult, {
    double value = 0,
    List<Milestone> milestones = const [],
    String note = '',
  }) async {
    final updated = switch (keyResult.type) {
      KeyResultType.percent => keyResult.copyWith(value: value.roundToDouble().clamp(0, 100)),
      KeyResultType.numeric => keyResult.copyWith(
          value: value.clamp(
            min(keyResult.start, keyResult.target),
            max(keyResult.start, keyResult.target) * 2,
          ),
        ),
      KeyResultType.milestones => keyResult.copyWith(milestones: milestones),
    };
    final change = _changeBetween(keyResult, updated);
    final trimmedNote = note.trim();
    var next = objective.replacingKeyResult(updated);
    final hasCheckin = change != null || trimmedNote.isNotEmpty;
    if (hasCheckin) {
      final now = _clock();
      next = next.withCheckin(
        Checkin(id: 'c${now.microsecondsSinceEpoch}', date: now, text: trimmedNote, change: change),
      );
    }
    await _gateway.save(next);
    return hasCheckin;
  }

  ProgressChange? _changeBetween(KeyResult before, KeyResult after) => switch (before.type) {
        KeyResultType.numeric when before.value != after.value => ProgressChange(
            kind: ProgressChangeKind.value,
            subject: before.title,
            from: before.value,
            to: after.value,
            unit: before.unit,
          ),
        KeyResultType.percent when before.value != after.value => ProgressChange(
            kind: ProgressChangeKind.percent,
            subject: before.title,
            from: before.value,
            to: after.value,
          ),
        KeyResultType.milestones
            when before.doneCount != after.doneCount ||
                before.milestones.length != after.milestones.length =>
          ProgressChange(
            kind: ProgressChangeKind.milestones,
            subject: before.title,
            from: before.doneCount.toDouble(),
            to: after.doneCount.toDouble(),
            total: after.milestones.length,
          ),
        _ => null,
      };
}
