import '../gateways/objective_gateway.dart';

class ReorderObjectivesUseCase {
  ReorderObjectivesUseCase(this._gateway);

  final ObjectiveGateway _gateway;

  Future<void> call(List<String> orderedIds) => _gateway.reorder(orderedIds);
}
