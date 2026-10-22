import 'package:flutter_test/flutter_test.dart';
import 'package:kaizen365/layers/functional/objectives/domain/entities/key_result.dart';
import 'package:kaizen365/layers/functional/objectives/domain/entities/life_domain.dart';
import 'package:kaizen365/layers/functional/objectives/domain/entities/objective.dart';
import 'package:kaizen365/layers/functional/objectives/domain/entities/objective_sort.dart';
import 'package:kaizen365/layers/functional/objectives/domain/entities/year_review.dart';
import 'package:kaizen365/layers/functional/objectives/domain/gateways/objective_gateway.dart';
import 'package:kaizen365/layers/functional/objectives/domain/gateways/objective_preferences_gateway.dart';
import 'package:kaizen365/layers/functional/objectives/domain/gateways/year_review_gateway.dart';
import 'package:kaizen365/layers/functional/objectives/domain/use_cases/add_checkin_use_case.dart';
import 'package:kaizen365/layers/functional/objectives/domain/use_cases/delete_checkin_use_case.dart';
import 'package:kaizen365/layers/functional/objectives/domain/use_cases/delete_objective_use_case.dart';
import 'package:kaizen365/layers/functional/objectives/domain/use_cases/get_active_year_use_case.dart';
import 'package:kaizen365/layers/functional/objectives/domain/use_cases/reorder_objectives_use_case.dart';
import 'package:kaizen365/layers/functional/objectives/domain/use_cases/restore_objective_use_case.dart';
import 'package:kaizen365/layers/functional/objectives/domain/use_cases/sort_objectives_use_case.dart';
import 'package:kaizen365/layers/functional/objectives/domain/use_cases/toggle_milestone_use_case.dart';
import 'package:kaizen365/layers/functional/objectives/domain/use_cases/update_key_result_use_case.dart';
import 'package:kaizen365/layers/functional/objectives/domain/use_cases/watch_active_year_use_case.dart';
import 'package:kaizen365/layers/functional/objectives/domain/use_cases/watch_objectives_use_case.dart';
import 'package:kaizen365/layers/functional/objectives/presentation/cubit/objectives_cubit.dart';
import 'package:kaizen365/layers/functional/objectives/presentation/cubit/objectives_state.dart';
import 'package:kaizen365/layers/functional/objectives/presentation/cubit/objectives_use_cases.dart';

class _StreamingGateway implements ObjectiveGateway {
  var objectives = <Objective>[];
  final _listeners = <void Function(List<Objective>)>[];

  @override
  Stream<List<Objective>> watch() async* {
    yield objectives;
    yield* Stream<List<Objective>>.multi((controller) => _listeners.add(controller.add));
  }

  Future<void> _publish(List<Objective> next) async {
    objectives = next;
    for (final listener in _listeners) {
      listener(next);
    }
    await Future<void>.delayed(Duration.zero);
  }

  @override
  Future<void> save(Objective objective) => _publish([
    for (final o in objectives)
      if (o.id != objective.id) o,
    objective,
  ]);

  @override
  Future<void> delete(String objectiveId) => _publish([
    for (final o in objectives)
      if (o.id != objectiveId) o,
  ]);

  @override
  Future<void> reorder(List<String> orderedIds) =>
      _publish([...objectives]..sort((a, b) => orderedIds.indexOf(a.id).compareTo(orderedIds.indexOf(b.id))));

  @override
  Future<void> replaceAll(List<Objective> objectives) => _publish(objectives);
}

class _Years implements YearReviewGateway {
  @override
  int activeYear() => 2026;
  @override
  Stream<int> watchActiveYear() => Stream.value(2026);
  @override
  Future<void> setActiveYear(int year) async {}
  @override
  YearReview load(int year) => const YearReview();
  @override
  Future<void> save(int year, YearReview review) async {}
  @override
  Map<int, YearReview> loadAll() => {};
  @override
  Future<void> replaceAll(Map<int, YearReview> reviews, {required int activeYear}) async {}
}

class _Prefs implements ObjectivePreferencesGateway {
  @override
  ObjectiveSort sort() => ObjectiveSort.manual;
  @override
  Future<void> setSort(ObjectiveSort sort) async {}
}

void main() {
  late _StreamingGateway gateway;
  late ObjectivesCubit cubit;
  DateTime clock() => DateTime(2026, 10, 13);
  const percent = KeyResult(id: 'k', title: 'Avancement', type: KeyResultType.percent, value: 90);
  const objective = Objective(id: 'o', title: 'Finir', domain: LifeDomain.career, year: 2026, keyResults: [percent]);

  setUp(() async {
    gateway = _StreamingGateway()
      ..objectives = [objective, const Objective(id: 'b', title: 'B', domain: LifeDomain.health, year: 2026)];
    final years = _Years();
    cubit = ObjectivesCubit(
      ObjectivesUseCases(
        watchObjectives: WatchObjectivesUseCase(gateway),
        watchActiveYear: WatchActiveYearUseCase(years),
        getActiveYear: GetActiveYearUseCase(years),
        toggleMilestone: ToggleMilestoneUseCase(gateway, clock),
        updateKeyResult: UpdateKeyResultUseCase(gateway, clock),
        addCheckin: AddCheckinUseCase(gateway, clock),
        deleteCheckin: DeleteCheckinUseCase(gateway),
        deleteObjective: DeleteObjectiveUseCase(gateway),
        restoreObjective: RestoreObjectiveUseCase(gateway),
        reorder: ReorderObjectivesUseCase(gateway),
        getSort: GetObjectiveSortUseCase(_Prefs()),
        setSort: SetObjectiveSortUseCase(_Prefs()),
      ),
      clock,
    )..load();
    await Future<void>.delayed(Duration.zero);
  });

  tearDown(() => cubit.close());

  test('reaching 100 % celebrates the objective instead of a plain toast', () async {
    await cubit.updateKeyResult(objective, percent, value: 100);
    expect((cubit.state.notice, cubit.state.noticeSubject), (ObjectivesNotice.objectiveAchieved, 'Finir'));
  });

  test('progress below the goal only confirms the save', () async {
    await cubit.updateKeyResult(objective, percent, value: 95);
    expect(cubit.state.notice, ObjectivesNotice.progressSaved);
  });

  test('undo puts a deleted objective back at its place', () async {
    await cubit.deleteObjective(objective);
    expect([for (final o in cubit.state.objectives) o.id], ['b']);
    await cubit.undoDelete();
    expect([for (final o in cubit.state.objectives) o.id], ['o', 'b']);
  });

  test('reorder moves an objective', () async {
    await cubit.reorder(0, 2);
    expect([for (final o in cubit.state.objectives) o.id], ['b', 'o']);
  });
}
