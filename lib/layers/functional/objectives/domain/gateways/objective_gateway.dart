import '../entities/objective.dart';

abstract interface class ObjectiveGateway {
  Stream<List<Objective>> watch();

  Future<void> save(Objective objective);

  Future<void> delete(String objectiveId);

  /// Reorders the given objectives among themselves; the others keep their place.
  Future<void> reorder(List<String> orderedIds);

  /// Replaces every objective, as when restoring a backup.
  Future<void> replaceAll(List<Objective> objectives);
}
