import '../../../../technical/clock/clock.dart';
import '../entities/checkin.dart';
import '../entities/objective.dart';
import '../entities/progress.dart';
import '../entities/progress_change.dart';
import '../gateways/objective_gateway.dart';
import '../gateways/year_review_gateway.dart';

class StartNextYearUseCase {
  StartNextYearUseCase(this._objectiveGateway, this._yearGateway, this._clock);

  final ObjectiveGateway _objectiveGateway;
  final YearReviewGateway _yearGateway;
  final Clock _clock;

  /// Copies the carried, unfinished objectives of [year] into the next year, with their current progress,
  /// then makes the next year active. Returns the number of objectives carried over.
  Future<int> call(int year, List<Objective> objectives) async {
    final carriedIds = _yearGateway.load(year).carriedObjectiveIds;
    final carried = [
      for (final o in objectives)
        if (o.year == year && carriedIds.contains(o.id) && objectiveProgress(o) < 0.999) o,
    ];
    final now = _clock();
    for (final (i, objective) in carried.indexed) {
      final stamp = now.microsecondsSinceEpoch + i;
      await _objectiveGateway.save(
        Objective(
          id: 'o$stamp',
          title: objective.title,
          domain: objective.domain,
          year: year + 1,
          why: objective.why,
          keyResults: [for (final k in objective.keyResults) k.copyWith(id: '${k.id}-${year + 1}')],
          checkins: [
            Checkin(
              id: 'c$stamp',
              date: now,
              change: ProgressChange(kind: ProgressChangeKind.carriedOver, subject: '$year'),
            ),
          ],
        ),
      );
    }
    await _yearGateway.setActiveYear(year + 1);
    return carried.length;
  }
}
