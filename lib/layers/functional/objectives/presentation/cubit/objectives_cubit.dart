import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../technical/clock/clock.dart';
import '../../domain/entities/key_result.dart';
import '../../domain/entities/milestone.dart';
import '../../domain/entities/mood.dart';
import '../../domain/entities/objective.dart';
import '../../domain/use_cases/add_checkin_use_case.dart';
import '../../domain/use_cases/delete_objective_use_case.dart';
import '../../domain/use_cases/get_active_year_use_case.dart';
import '../../domain/use_cases/toggle_milestone_use_case.dart';
import '../../domain/use_cases/update_key_result_use_case.dart';
import '../../domain/use_cases/watch_active_year_use_case.dart';
import '../../domain/use_cases/watch_objectives_use_case.dart';
import 'objectives_state.dart';

class ObjectivesCubit extends Cubit<ObjectivesState> {
  ObjectivesCubit(
    this._watchObjectives,
    this._toggleMilestone,
    this._updateKeyResult,
    this._addCheckin,
    this._deleteObjective,
    this._watchActiveYear,
    GetActiveYearUseCase getActiveYear,
    this._clock,
  ) : super(ObjectivesState(now: _clock(), activeYear: getActiveYear()));

  final WatchObjectivesUseCase _watchObjectives;
  final ToggleMilestoneUseCase _toggleMilestone;
  final UpdateKeyResultUseCase _updateKeyResult;
  final AddCheckinUseCase _addCheckin;
  final DeleteObjectiveUseCase _deleteObjective;
  final WatchActiveYearUseCase _watchActiveYear;
  final Clock _clock;
  StreamSubscription<List<Objective>>? _subscription;
  StreamSubscription<int>? _yearSubscription;

  void load() {
    _watchYear();
    _subscription?.cancel();
    _subscription = _watchObjectives().listen(
      (objectives) => emit(state.copyWith(status: ObjectivesStatus.ready, allObjectives: objectives, now: _clock())),
      onError: (Object error, StackTrace stackTrace) {
        debugPrint('Objectives loading failed: $error\n$stackTrace');
        emit(state.copyWith(status: ObjectivesStatus.failure));
      },
    );
  }

  void _watchYear() {
    _yearSubscription?.cancel();
    _yearSubscription = _watchActiveYear().listen((year) => emit(state.copyWith(activeYear: year, now: _clock())));
  }

  Future<void> toggleMilestone(Objective objective, KeyResult keyResult, int index) => _guard(() async {
    final isDone = await _toggleMilestone(objective, keyResult, index);
    if (isDone) emit(state.withNotice(ObjectivesNotice.milestoneDone));
  });

  Future<void> updateKeyResult(
    Objective objective,
    KeyResult keyResult, {
    double value = 0,
    List<Milestone> milestones = const [],
    String note = '',
  }) => _guard(() async {
    final hasCheckin = await _updateKeyResult(objective, keyResult, value: value, milestones: milestones, note: note);
    if (hasCheckin) emit(state.withNotice(ObjectivesNotice.progressSaved));
  });

  Future<void> addCheckin(Objective objective, {required Mood? mood, required String text}) => _guard(() async {
    await _addCheckin(objective, mood: mood, text: text);
    emit(state.withNotice(ObjectivesNotice.checkinPublished));
  });

  void notifyCreated() => emit(state.withNotice(ObjectivesNotice.objectiveCreated));

  void notifyUpdated() => emit(state.withNotice(ObjectivesNotice.objectiveUpdated));

  Future<void> deleteObjective(Objective objective) => _guard(() async {
    await _deleteObjective(objective.id);
    emit(state.withNotice(ObjectivesNotice.objectiveDeleted));
  });

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
