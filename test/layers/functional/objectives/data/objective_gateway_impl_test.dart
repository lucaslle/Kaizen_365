import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:kaizen365/layers/functional/objectives/data/data_sources/objective_local_data_source.dart';
import 'package:kaizen365/layers/functional/objectives/data/gateways/objective_gateway_impl.dart';
import 'package:kaizen365/layers/functional/objectives/domain/entities/life_domain.dart';
import 'package:kaizen365/layers/functional/objectives/domain/entities/objective.dart';

void main() {
  late Directory directory;

  setUp(() async => directory = await Directory.systemTemp.createTemp('kaizen'));
  tearDown(() => directory.delete(recursive: true));

  Objective objective(String id, int year) => Objective(id: id, title: id, domain: LifeDomain.health, year: year);

  test('reorder moves the given objectives among themselves and persists the order', () async {
    final gateway = ObjectiveGatewayImpl(ObjectiveLocalDataSource(() async => directory));
    for (final o in [objective('a', 2026), objective('old', 2025), objective('b', 2026), objective('c', 2026)]) {
      await gateway.save(o);
    }
    await gateway.reorder(['c', 'a', 'b']);
    final reloaded = ObjectiveGatewayImpl(ObjectiveLocalDataSource(() async => directory));
    expect([for (final o in await reloaded.watch().first) o.id], ['c', 'old', 'a', 'b']);
  });

  test('delete then replace all', () async {
    final gateway = ObjectiveGatewayImpl(ObjectiveLocalDataSource(() async => directory));
    await gateway.save(objective('a', 2026));
    await gateway.save(objective('b', 2026));
    await gateway.delete('a');
    expect([for (final o in await gateway.watch().first) o.id], ['b']);
    await gateway.replaceAll([objective('z', 2027)]);
    expect([for (final o in await gateway.watch().first) o.id], ['z']);
  });
}
