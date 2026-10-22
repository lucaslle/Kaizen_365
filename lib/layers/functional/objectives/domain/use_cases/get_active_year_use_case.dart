import '../gateways/year_review_gateway.dart';

class GetActiveYearUseCase {
  GetActiveYearUseCase(this._gateway);

  final YearReviewGateway _gateway;

  int call() => _gateway.activeYear();
}
