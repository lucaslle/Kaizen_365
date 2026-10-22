import '../../../../technical/clock/clock.dart';
import '../entities/checkin.dart';
import '../entities/mood.dart';
import '../entities/objective.dart';
import '../gateways/objective_gateway.dart';

class AddCheckinUseCase {
  AddCheckinUseCase(this._gateway, this._clock);

  final ObjectiveGateway _gateway;
  final Clock _clock;

  Future<void> call(Objective objective, {required Mood? mood, required String text}) {
    final now = _clock();
    final checkin = Checkin(id: 'c${now.microsecondsSinceEpoch}', date: now, mood: mood, text: text.trim());
    return _gateway.save(objective.withCheckin(checkin));
  }
}
