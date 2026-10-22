import '../entities/checkin_revert.dart';
import '../entities/objective.dart';
import '../gateways/objective_gateway.dart';

class DeleteCheckinUseCase {
  DeleteCheckinUseCase(this._gateway);

  final ObjectiveGateway _gateway;

  Future<void> call(Objective objective, String checkinId) => _gateway.save(objective.withoutCheckin(checkinId));
}
