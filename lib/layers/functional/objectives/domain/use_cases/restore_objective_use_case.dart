import '../entities/objective.dart';
import '../gateways/objective_gateway.dart';

class RestoreObjectiveUseCase {
  RestoreObjectiveUseCase(this._gateway);

  final ObjectiveGateway _gateway;

  /// Puts a deleted objective back at its former place.
  Future<void> call(Objective objective, List<String> previousOrder) async {
    await _gateway.save(objective);
    await _gateway.reorder(previousOrder);
  }
}
