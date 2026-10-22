import 'dart:async';

import 'package:kaizen365/layers/functional/objectives/domain/entities/objective.dart';
import 'package:kaizen365/layers/functional/objectives/domain/gateways/objective_gateway.dart';

class FakeObjectiveGateway implements ObjectiveGateway {
  final saved = <Objective>[];

  @override
  Future<void> save(Objective objective) async => saved.add(objective);

  @override
  Stream<List<Objective>> watch() => Stream.value(saved);
}
