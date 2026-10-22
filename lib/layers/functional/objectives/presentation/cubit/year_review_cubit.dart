import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../technical/clock/clock.dart';
import '../../domain/entities/objective.dart';
import '../../domain/entities/year_review.dart';
import '../../domain/use_cases/get_active_year_use_case.dart';
import '../../domain/use_cases/get_year_review_use_case.dart';
import '../../domain/use_cases/save_year_review_use_case.dart';
import '../../domain/use_cases/start_next_year_use_case.dart';
import '../../domain/use_cases/watch_active_year_use_case.dart';
import '../../domain/use_cases/watch_objectives_use_case.dart';
import 'year_review_state.dart';

class YearReviewCubit extends Cubit<YearReviewState> {
  YearReviewCubit(
    GetActiveYearUseCase getActiveYear,
    this._getReview,
    this._saveReview,
    this._watchObjectives,
    this._watchActiveYear,
    this._startNextYear,
    this._clock,
  ) : super(_initialState(getActiveYear(), _getReview, _clock));

  final GetYearReviewUseCase _getReview;
  final SaveYearReviewUseCase _saveReview;
  final WatchObjectivesUseCase _watchObjectives;
  final WatchActiveYearUseCase _watchActiveYear;
  final StartNextYearUseCase _startNextYear;
  final Clock _clock;
  StreamSubscription<List<Objective>>? _subscription;
  StreamSubscription<int>? _yearSubscription;

  static YearReviewState _initialState(int year, GetYearReviewUseCase getReview, Clock clock) =>
      YearReviewState(year: year, review: getReview(year), now: clock());

  void load() {
    _subscription?.cancel();
    _subscription = _watchObjectives().listen(
      (objectives) => emit(state.copyWith(allObjectives: objectives, now: _clock())),
      onError: (Object error, StackTrace stackTrace) => debugPrint('Year review loading failed: $error\n$stackTrace'),
    );
    _yearSubscription?.cancel();
    _yearSubscription = _watchActiveYear().listen(
      (year) => emit(state.copyWith(year: year, review: _getReview(year), now: _clock())),
    );
  }

  void carryToggled(String objectiveId) {
    final ids = {...state.review.carriedObjectiveIds};
    if (!ids.remove(objectiveId)) ids.add(objectiveId);
    _update(state.review.copyWith(carriedObjectiveIds: ids));
  }

  void reflectionChanged(Reflection reflection, String text) =>
      _update(state.review.copyWith(reflections: {...state.review.reflections, reflection: text}));

  void closeYear() {
    _update(state.review.copyWith(isClosed: true));
    emit(state.copyWith(hasJustClosed: true));
  }

  Future<void> startNextYear() async {
    try {
      final carriedCount = await _startNextYear(state.year, state.allObjectives);
      emit(state.copyWith(startedYearCarriedCount: carriedCount));
    } catch (error, stackTrace) {
      debugPrint('Starting next year failed: $error\n$stackTrace');
    }
  }

  void _update(YearReview review) {
    emit(state.copyWith(review: review));
    _saveReview(state.year, review).catchError((Object error) => debugPrint('Year review save failed: $error'));
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    await _yearSubscription?.cancel();
    return super.close();
  }
}
