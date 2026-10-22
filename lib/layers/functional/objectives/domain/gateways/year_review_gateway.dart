import '../entities/year_review.dart';

abstract interface class YearReviewGateway {
  YearReview load();

  Future<void> save(YearReview review);
}
