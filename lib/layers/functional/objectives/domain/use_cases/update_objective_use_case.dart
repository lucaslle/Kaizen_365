import '../entities/key_result.dart';
import '../entities/life_domain.dart';
import '../entities/objective.dart';
import '../gateways/objective_gateway.dart';

class UpdateObjectiveUseCase {
  UpdateObjectiveUseCase(this._gateway);

  final ObjectiveGateway _gateway;

  Future<Objective> call(
    Objective objective, {
    required String title,
    required LifeDomain domain,
    required String why,
    required List<KeyResult> keyResults,
  }) async {
    final updated = objective.copyWith(title: title.trim(), domain: domain, why: why.trim(), keyResults: keyResults);
    await _gateway.save(updated);
    return updated;
  }
}
