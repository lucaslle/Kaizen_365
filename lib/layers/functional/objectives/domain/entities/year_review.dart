enum Reflection { proud, learned, next }

class YearReview {
  const YearReview({this.isClosed = false, this.carriedObjectiveIds = const {}, this.reflections = const {}});

  final bool isClosed;
  final Set<String> carriedObjectiveIds;
  final Map<Reflection, String> reflections;

  YearReview copyWith({bool? isClosed, Set<String>? carriedObjectiveIds, Map<Reflection, String>? reflections}) =>
      YearReview(
        isClosed: isClosed ?? this.isClosed,
        carriedObjectiveIds: carriedObjectiveIds ?? this.carriedObjectiveIds,
        reflections: reflections ?? this.reflections,
      );
}
