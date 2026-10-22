import 'dart:async';

import '../../domain/entities/objective.dart';
import '../../domain/gateways/objective_gateway.dart';
import '../data_sources/objective_local_data_source.dart';
import '../models/objective_dto.dart';

class ObjectiveGatewayImpl implements ObjectiveGateway {
  ObjectiveGatewayImpl(this._dataSource);

  final ObjectiveLocalDataSource _dataSource;
  final _changes = StreamController<List<Objective>>.broadcast();
  List<Objective>? _cache;
  Future<void> _pendingWrite = Future.value();

  Future<List<Objective>> _objectives() async =>
      _cache ??= (await _dataSource.read()).map(ObjectiveDto.fromJson).toList();

  @override
  Stream<List<Objective>> watch() async* {
    yield await _objectives();
    yield* _changes.stream;
  }

  @override
  Future<void> save(Objective objective) async {
    final current = await _objectives();
    final exists = current.any((o) => o.id == objective.id);
    await _publish(exists ? [for (final o in current) o.id == objective.id ? objective : o] : [...current, objective]);
  }

  @override
  Future<void> delete(String objectiveId) async => _publish([
    for (final o in await _objectives())
      if (o.id != objectiveId) o,
  ]);

  Future<void> _publish(List<Objective> objectives) async {
    final next = List<Objective>.unmodifiable(objectives);
    _cache = next;
    _changes.add(next);
    _pendingWrite = _pendingWrite
        .catchError((Object _) {})
        .then((_) => _dataSource.write(next.map(ObjectiveDto.toJson).toList()));
    await _pendingWrite;
  }
}
