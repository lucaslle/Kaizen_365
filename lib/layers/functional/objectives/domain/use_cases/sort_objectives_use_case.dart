import '../entities/objective_sort.dart';
import '../gateways/objective_preferences_gateway.dart';

class GetObjectiveSortUseCase {
  GetObjectiveSortUseCase(this._gateway);

  final ObjectivePreferencesGateway _gateway;

  ObjectiveSort call() => _gateway.sort();
}

class SetObjectiveSortUseCase {
  SetObjectiveSortUseCase(this._gateway);

  final ObjectivePreferencesGateway _gateway;

  Future<void> call(ObjectiveSort sort) => _gateway.setSort(sort);
}
