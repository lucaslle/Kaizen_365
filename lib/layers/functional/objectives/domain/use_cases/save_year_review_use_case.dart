import '../entities/year_review.dart';
import '../gateways/year_review_gateway.dart';

class SaveYearReviewUseCase {
  SaveYearReviewUseCase(this._gateway);

  final YearReviewGateway _gateway;

  Future<void> call(YearReview review) => _gateway.save(review);
}
