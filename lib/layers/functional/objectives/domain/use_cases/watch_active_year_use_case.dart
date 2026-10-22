import '../gateways/year_review_gateway.dart';

class WatchActiveYearUseCase {
  WatchActiveYearUseCase(this._gateway);

  final YearReviewGateway _gateway;

  Stream<int> call() => _gateway.watchActiveYear();
}
