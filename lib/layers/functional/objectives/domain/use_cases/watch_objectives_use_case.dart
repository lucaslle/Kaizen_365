import '../entities/objective.dart';
import '../gateways/objective_gateway.dart';

class WatchObjectivesUseCase {
  WatchObjectivesUseCase(this._gateway);

  final ObjectiveGateway _gateway;

  Stream<List<Objective>> call() => _gateway.watch();
}
