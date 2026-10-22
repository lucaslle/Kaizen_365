import 'package:flutter_test/flutter_test.dart';
import 'package:kaizen365/layers/functional/objectives/domain/entities/checkin.dart';
import 'package:kaizen365/layers/functional/objectives/domain/entities/life_domain.dart';
import 'package:kaizen365/layers/functional/objectives/domain/entities/objective.dart';
import 'package:kaizen365/layers/functional/objectives/domain/entities/progress_change.dart';
import 'package:kaizen365/layers/functional/objectives/presentation/cubit/journal_filter_cubit.dart';

void main() {
  const running = Objective(id: 'run', title: 'Courir un semi', domain: LifeDomain.health, year: 2026);
  const reading = Objective(id: 'read', title: 'Lire 24 livres', domain: LifeDomain.wellBeing, year: 2026);
  final knee = Checkin(id: '1', date: DateTime(2026), text: 'Douleur au GENOU');
  final pages = Checkin(
    id: '2',
    date: DateTime(2026),
    change: const ProgressChange(kind: ProgressChangeKind.value, subject: 'Pages lues'),
  );

  test('search matches text, objective title and key result, case-insensitively', () {
    expect(const JournalFilter(query: 'genou').matches(knee, running), isTrue);
    expect(const JournalFilter(query: 'semi').matches(knee, running), isTrue);
    expect(const JournalFilter(query: 'pages').matches(pages, reading), isTrue);
    expect(const JournalFilter(query: 'pages').matches(knee, running), isFalse);
  });

  test('the objective filter and the search combine', () {
    expect(const JournalFilter(objectiveId: 'read', query: 'genou').matches(knee, running), isFalse);
    expect(const JournalFilter(objectiveId: 'run').matches(knee, running), isTrue);
  });
}
