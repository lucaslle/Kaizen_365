import '../../domain/entities/objective.dart';
import '../../domain/entities/year_review.dart';

class YearReviewState {
  const YearReviewState({
    required this.review,
    required this.now,
    this.objectives = const [],
    this.hasJustClosed = false,
  });

  final YearReview review;
  final DateTime now;
  final List<Objective> objectives;
  final bool hasJustClosed;

  YearReviewState copyWith({YearReview? review, List<Objective>? objectives, DateTime? now, bool? hasJustClosed}) =>
      YearReviewState(
        review: review ?? this.review,
        now: now ?? this.now,
        objectives: objectives ?? this.objectives,
        hasJustClosed: hasJustClosed ?? false,
      );
}
