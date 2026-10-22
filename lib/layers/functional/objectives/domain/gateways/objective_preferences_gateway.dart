import '../entities/objective_sort.dart';

abstract interface class ObjectivePreferencesGateway {
  ObjectiveSort sort();

  Future<void> setSort(ObjectiveSort sort);
}
