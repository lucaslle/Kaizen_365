import '../entities/year_review.dart';
import '../gateways/year_review_gateway.dart';

class GetYearReviewUseCase {
  GetYearReviewUseCase(this._gateway);

  final YearReviewGateway _gateway;

  YearReview call() => _gateway.load();
}
