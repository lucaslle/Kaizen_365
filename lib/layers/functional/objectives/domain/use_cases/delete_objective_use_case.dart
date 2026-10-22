import '../gateways/objective_gateway.dart';

class DeleteObjectiveUseCase {
  DeleteObjectiveUseCase(this._gateway);

  final ObjectiveGateway _gateway;

  Future<void> call(String objectiveId) => _gateway.delete(objectiveId);
}
