import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../technical/clock/clock.dart';
import '../../domain/entities/key_result.dart';
import '../../domain/entities/milestone.dart';
import '../../domain/entities/mood.dart';
import '../../domain/entities/objective.dart';
import '../../domain/entities/objective_sort.dart';
import '../../domain/entities/progress.dart';
import 'objectives_state.dart';
import 'objectives_use_cases.dart';

class ObjectivesCubit extends Cubit<ObjectivesState> {
  ObjectivesCubit(this._useCases, this._clock)
    : super(ObjectivesState(now: _clock(), activeYear: _useCases.getActiveYear(), sort: _useCases.getSort()));

  final ObjectivesUseCases _useCases;
  final Clock _clock;
  StreamSubscription<List<Objective>>? _subscription;
  StreamSubscription<int>? _yearSubscription;
  ({Objective objective, List<String> order})? _lastDeleted;

  void load() {
    _yearSubscription?.cancel();
    _yearSubscription = _useCases.watchActiveYear().listen(
      (year) => emit(state.copyWith(activeYear: year, now: _clock())),
    );
    _subscription?.cancel();
    _subscription = _useCases.watchObjectives().listen(
      (objectives) => emit(state.copyWith(status: ObjectivesStatus.ready, allObjectives: objectives, now: _clock())),
      onError: (Object error, StackTrace stackTrace) {
        debugPrint('Objectives loading failed: $error\n$stackTrace');
        emit(state.copyWith(status: ObjectivesStatus.failure));
      },
    );
  }

  Future<void> toggleMilestone(Objective objective, KeyResult keyResult, int index) => _guard(() async {
    final isDone = await _useCases.toggleMilestone(objective, keyResult, index);
    if (!_celebrateIfAchieved(objective) && isDone) emit(state.withNotice(ObjectivesNotice.milestoneDone));
  });

  Future<void> updateKeyResult(
    Objective objective,
    KeyResult keyResult, {
    double value = 0,
    List<Milestone> milestones = const [],
    String note = '',
  }) => _guard(() async {
    final hasCheckin = await _useCases.updateKeyResult(
      objective,
      keyResult,
      value: value,
      milestones: milestones,
      note: note,
    );
    if (!_celebrateIfAchieved(objective) && hasCheckin) emit(state.withNotice(ObjectivesNotice.progressSaved));
  });

  Future<void> addCheckin(Objective objective, {required Mood? mood, required String text}) => _guard(() async {
    await _useCases.addCheckin(objective, mood: mood, text: text);
    emit(state.withNotice(ObjectivesNotice.checkinPublished));
  });

  Future<void> deleteCheckin(Objective objective, String checkinId) => _guard(() async {
    await _useCases.deleteCheckin(objective, checkinId);
    emit(state.withNotice(ObjectivesNotice.checkinDeleted));
  });

  void notifyCreated() => emit(state.withNotice(ObjectivesNotice.objectiveCreated));

  void notifyUpdated() => emit(state.withNotice(ObjectivesNotice.objectiveUpdated));

  Future<void> deleteObjective(Objective objective) => _guard(() async {
    _lastDeleted = (objective: objective, order: [for (final o in state.allObjectives) o.id]);
    await _useCases.deleteObjective(objective.id);
    emit(state.withNotice(ObjectivesNotice.objectiveDeleted, subject: objective.title));
  });

  Future<void> undoDelete() => _guard(() async {
    final deleted = _lastDeleted;
    if (deleted == null) return;
    _lastDeleted = null;
    await _useCases.restoreObjective(deleted.objective, deleted.order);
  });

  Future<void> reorder(int oldIndex, int newIndex) => _guard(() async {
    final ids = [for (final o in state.objectives) o.id];
    ids.insert(newIndex > oldIndex ? newIndex - 1 : newIndex, ids.removeAt(oldIndex));
    await _useCases.reorder(ids);
  });

  Future<void> sortSelected(ObjectiveSort sort) => _guard(() async {
    emit(state.copyWith(sort: sort));
    await _useCases.setSort(sort);
  });

  /// The stream has already delivered the saved objective when the use case returns.
  bool _celebrateIfAchieved(Objective before) {
    final after = state.byId(before.id);
    if (after == null || objectiveProgress(before) >= 0.999 || objectiveProgress(after) < 0.999) return false;
    emit(state.withNotice(ObjectivesNotice.objectiveAchieved, subject: after.title));
    return true;
  }

  Future<void> _guard(Future<void> Function() action) async {
    try {
      await action();
    } catch (error, stackTrace) {
      debugPrint('Objective update failed: $error\n$stackTrace');
      emit(state.withNotice(ObjectivesNotice.saveFailed));
    }
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    await _yearSubscription?.cancel();
    return super.close();
  }
}
