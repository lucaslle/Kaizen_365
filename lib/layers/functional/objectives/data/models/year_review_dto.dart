import '../../domain/entities/year_review.dart';

abstract final class YearReviewDto {
  static Map<String, dynamic> toJson(YearReview review) => {
    'isClosed': review.isClosed,
    'carriedObjectiveIds': review.carriedObjectiveIds.toList(),
    'reflections': {for (final MapEntry(:key, :value) in review.reflections.entries) key.name: value},
  };

  static YearReview fromJson(Map<String, dynamic> json) => YearReview(
    isClosed: json['isClosed'] as bool,
    carriedObjectiveIds: {...(json['carriedObjectiveIds'] as List).cast<String>()},
    reflections: {
      for (final MapEntry(:key, :value) in (json['reflections'] as Map<String, dynamic>).entries)
        Reflection.values.byName(key): value as String,
    },
  );
}
