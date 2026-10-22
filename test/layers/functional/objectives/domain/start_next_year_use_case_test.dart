import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:kaizen365/layers/functional/objectives/domain/entities/checkin.dart';
import 'package:kaizen365/layers/functional/objectives/domain/entities/key_result.dart';
import 'package:kaizen365/layers/functional/objectives/domain/entities/life_domain.dart';
import 'package:kaizen365/layers/functional/objectives/domain/entities/objective.dart';
import 'package:kaizen365/layers/functional/objectives/domain/entities/progress_change.dart';
import 'package:kaizen365/layers/functional/objectives/domain/entities/year_review.dart';
import 'package:kaizen365/layers/functional/objectives/domain/gateways/year_review_gateway.dart';
import 'package:kaizen365/layers/functional/objectives/domain/use_cases/start_next_year_use_case.dart';

import '../fake_objective_gateway.dart';

class _FakeYearGateway implements YearReviewGateway {
  _FakeYearGateway(this.review);

  final YearReview review;
  int? active;

  @override
  int activeYear() => active ?? 2026;

  @override
  Stream<int> watchActiveYear() => const Stream.empty();

  @override
  Future<void> setActiveYear(int year) async => active = year;

  @override
  YearReview load(int year) => year == 2026 ? review : const YearReview();

  @override
  Future<void> save(int year, YearReview review) async {}

  @override
  Map<int, YearReview> loadAll() => {2026: review};

  @override
  Future<void> replaceAll(Map<int, YearReview> reviews, {required int activeYear}) async {}
}

Objective _objective(String id, double percent, {int year = 2026}) => Objective(
  id: id,
  title: id,
  domain: LifeDomain.health,
  year: year,
  keyResults: [KeyResult(id: 'k-$id', title: 'Avancement', type: KeyResultType.percent, value: percent)],
  checkins: [Checkin(id: 'c-$id', date: DateTime(2026, 2, 1), text: 'Ancien')],
);

void main() {
  test(
    'carries unfinished, selected objectives of the year with their progress, then activates the next year',
    () async {
      final objectives = [
        _objective('carried', 40),
        _objective('not-selected', 40),
        _objective('done', 100),
        _objective('other-year', 10, year: 2025),
      ];
      final gateway = FakeObjectiveGateway();
      final years = _FakeYearGateway(
        const YearReview(isClosed: true, carriedObjectiveIds: {'carried', 'done', 'other-year'}),
      );

      final count = await StartNextYearUseCase(gateway, years, () => DateTime(2026, 12, 31))(2026, objectives);

      expect(count, 1);
      expect(years.active, 2027);
      final copy = gateway.saved.single;
      expect((copy.title, copy.year), ('carried', 2027));
      expect(copy.id, isNot('carried'));
      expect(copy.keyResults.single.value, 40);
      expect(copy.keyResults.single.id, isNot('k-carried'));
      final checkin = copy.checkins.single;
      expect((checkin.change!.kind, checkin.change!.subject), (ProgressChangeKind.carriedOver, '2026'));
    },
  );

  test('with nothing carried, the next year still starts', () async {
    final years = _FakeYearGateway(const YearReview(isClosed: true));
    final count = await StartNextYearUseCase(FakeObjectiveGateway(), years, () => DateTime(2026, 12, 31))(2026, [
      _objective('a', 10),
    ]);
    expect((count, years.active), (0, 2027));
  });
}
