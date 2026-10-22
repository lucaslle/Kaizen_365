import '../../domain/entities/objective.dart';
import '../../domain/entities/year_review.dart';

class YearReviewState {
  const YearReviewState({
    required this.year,
    required this.activeYear,
    required this.review,
    required this.now,
    this.allObjectives = const [],
    this.hasJustClosed = false,
    this.startedYearCarriedCount,
  });

  /// The year shown, which may be a past one.
  final int year;
  final int activeYear;
  final YearReview review;
  final DateTime now;
  final List<Objective> allObjectives;
  final bool hasJustClosed;

  /// Set once, right after the next year has started, with the number of objectives carried over.
  final int? startedYearCarriedCount;

  List<Objective> get objectives => [
    for (final o in allObjectives)
      if (o.year == year) o,
  ];

  bool get isActiveYear => year == activeYear;

  List<int> get availableYears => ({for (final o in allObjectives) o.year}..add(activeYear)).toList()..sort();

  YearReviewState copyWith({
    int? year,
    int? activeYear,
    YearReview? review,
    List<Objective>? allObjectives,
    DateTime? now,
    bool? hasJustClosed,
    int? startedYearCarriedCount,
  }) => YearReviewState(
    year: year ?? this.year,
    activeYear: activeYear ?? this.activeYear,
    review: review ?? this.review,
    now: now ?? this.now,
    allObjectives: allObjectives ?? this.allObjectives,
    hasJustClosed: hasJustClosed ?? false,
    startedYearCarriedCount: startedYearCarriedCount,
  );
}
