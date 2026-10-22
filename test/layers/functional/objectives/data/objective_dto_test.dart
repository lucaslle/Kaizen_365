import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:kaizen365/layers/functional/objectives/data/models/objective_dto.dart';
import 'package:kaizen365/layers/functional/objectives/domain/entities/checkin.dart';
import 'package:kaizen365/layers/functional/objectives/domain/entities/key_result.dart';
import 'package:kaizen365/layers/functional/objectives/domain/entities/life_domain.dart';
import 'package:kaizen365/layers/functional/objectives/domain/entities/milestone.dart';
import 'package:kaizen365/layers/functional/objectives/domain/entities/mood.dart';
import 'package:kaizen365/layers/functional/objectives/domain/entities/objective.dart';
import 'package:kaizen365/layers/functional/objectives/domain/entities/progress_change.dart';

void main() {
  test('an objective survives a JSON round trip', () {
    final objective = Objective(
      id: 'o1',
      title: 'Épargner 6 000 €',
      domain: LifeDomain.finances,
      why: 'Japon',
      keyResults: const [
        KeyResult(id: 'k1', title: 'Montant', type: KeyResultType.numeric, value: 4900, target: 6000, unit: '€', step: 100),
        KeyResult(id: 'k2', title: 'Budget', type: KeyResultType.milestones, milestones: [Milestone(title: 'Livret', isDone: true)]),
      ],
      checkins: [
        Checkin(
          id: 'c1',
          date: DateTime(2026, 10, 1),
          mood: Mood.up,
          text: 'On approche',
          change: const ProgressChange(kind: ProgressChangeKind.value, subject: 'Montant', from: 4400, to: 4900, unit: '€'),
        ),
        Checkin(id: 'c2', date: DateTime(2026, 9, 1)),
      ],
    );
    final restored = ObjectiveDto.fromJson(
      jsonDecode(jsonEncode(ObjectiveDto.toJson(objective))) as Map<String, dynamic>,
    );
    expect(jsonEncode(ObjectiveDto.toJson(restored)), jsonEncode(ObjectiveDto.toJson(objective)));
    expect(restored.domain, LifeDomain.finances);
    expect(restored.keyResults.last.milestones.single.isDone, isTrue);
    expect(restored.checkins.first.change!.to, 4900);
    expect(restored.checkins.last.mood, isNull);
  });
}
