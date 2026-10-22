import '../entities/year_review.dart';

abstract interface class YearReviewGateway {
  int activeYear();

  Stream<int> watchActiveYear();

  Future<void> setActiveYear(int year);

  YearReview load(int year);

  Future<void> save(int year, YearReview review);
}
