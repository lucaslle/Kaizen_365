import '../entities/objective.dart';

abstract interface class ObjectiveGateway {
  Stream<List<Objective>> watch();

  Future<void> save(Objective objective);

  Future<void> delete(String objectiveId);
}
