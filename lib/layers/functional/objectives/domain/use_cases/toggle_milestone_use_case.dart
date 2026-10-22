import '../../../../technical/clock/clock.dart';
import '../entities/checkin.dart';
import '../entities/key_result.dart';
import '../entities/objective.dart';
import '../entities/progress_change.dart';
import '../gateways/objective_gateway.dart';

class ToggleMilestoneUseCase {
  ToggleMilestoneUseCase(this._gateway, this._clock);

  final ObjectiveGateway _gateway;
  final Clock _clock;

  /// Returns true when the milestone became done.
  Future<bool> call(Objective objective, KeyResult keyResult, int index) async {
    final milestone = keyResult.milestones[index];
    final milestones = [...keyResult.milestones]..[index] = milestone.toggled();
    var updated = objective.replacingKeyResult(keyResult.copyWith(milestones: milestones));
    if (!milestone.isDone) {
      final now = _clock();
      updated = updated.withCheckin(
        Checkin(
          id: 'c${now.microsecondsSinceEpoch}',
          date: now,
          change: ProgressChange(
            kind: ProgressChangeKind.milestoneDone,
            subject: milestone.title,
            keyResultId: keyResult.id,
          ),
        ),
      );
    }
    await _gateway.save(updated);
    return !milestone.isDone;
  }
}
