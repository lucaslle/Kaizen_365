import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../technical/clock/clock.dart';
import '../../domain/entities/objective.dart';
import '../../domain/use_cases/watch_objectives_use_case.dart';
import '../../domain/entities/year_review.dart';
import '../../domain/use_cases/get_year_review_use_case.dart';
import '../../domain/use_cases/save_year_review_use_case.dart';
import 'year_review_state.dart';

class YearReviewCubit extends Cubit<YearReviewState> {
  YearReviewCubit(GetYearReviewUseCase getReview, this._saveReview, this._watchObjectives, this._clock)
      : super(YearReviewState(review: getReview(), now: _clock()));

  final SaveYearReviewUseCase _saveReview;
  final WatchObjectivesUseCase _watchObjectives;
  final Clock _clock;
  StreamSubscription<List<Objective>>? _subscription;

  void load() {
    _subscription?.cancel();
    _subscription = _watchObjectives().listen(
      (objectives) => emit(state.copyWith(objectives: objectives, now: _clock())),
      onError: (Object error, StackTrace stackTrace) => debugPrint('Year review loading failed: $error\n$stackTrace'),
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

  void _update(YearReview review) {
    emit(state.copyWith(review: review));
    _saveReview(review).catchError((Object error) => debugPrint('Year review save failed: $error'));
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
