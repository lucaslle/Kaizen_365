import '../../../../technical/clock/clock.dart';
import '../entities/checkin.dart';
import '../entities/key_result.dart';
import '../entities/life_domain.dart';
import '../entities/mood.dart';
import '../entities/objective.dart';
import '../entities/progress_change.dart';
import '../gateways/objective_gateway.dart';

class CreateObjectiveUseCase {
  CreateObjectiveUseCase(this._gateway, this._clock);

  final ObjectiveGateway _gateway;
  final Clock _clock;

  Future<Objective> call({
    required String title,
    required LifeDomain domain,
    required String why,
    required List<KeyResult> keyResults,
  }) async {
    final now = _clock();
    final id = 'o${now.microsecondsSinceEpoch}';
    final objective = Objective(
      id: id,
      title: title.trim(),
      domain: domain,
      why: why.trim(),
      keyResults: keyResults,
      checkins: [
        Checkin(
          id: 'c${now.microsecondsSinceEpoch}',
          date: now,
          mood: Mood.up,
          change: const ProgressChange(kind: ProgressChangeKind.created),
        ),
      ],
    );
    await _gateway.save(objective);
    return objective;
  }
}
