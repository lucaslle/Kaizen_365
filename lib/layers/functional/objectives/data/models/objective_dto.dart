import '../../domain/entities/checkin.dart';
import '../../domain/entities/key_result.dart';
import '../../domain/entities/life_domain.dart';
import '../../domain/entities/milestone.dart';
import '../../domain/entities/mood.dart';
import '../../domain/entities/objective.dart';
import '../../domain/entities/progress_change.dart';

abstract final class ObjectiveDto {
  static Map<String, dynamic> toJson(Objective o) => {
    'id': o.id,
    'title': o.title,
    'domain': o.domain.name,
    'year': o.year,
    'why': o.why,
    'keyResults': [for (final k in o.keyResults) _keyResultToJson(k)],
    'checkins': [for (final c in o.checkins) _checkinToJson(c)],
  };

  static Objective fromJson(Map<String, dynamic> json) {
    final checkins = [for (final c in json['checkins'] as List) _checkinFromJson(c as Map<String, dynamic>)];
    return Objective(
      id: json['id'] as String,
      title: json['title'] as String,
      domain: LifeDomain.values.byName(json['domain'] as String),
      year: json['year'] as int? ?? _creationYear(checkins),
      why: json['why'] as String? ?? '',
      keyResults: [for (final k in json['keyResults'] as List) _keyResultFromJson(k as Map<String, dynamic>)],
      checkins: checkins,
    );
  }

  /// Objectives saved before years were tracked belong to the year of their first check-in.
  static int _creationYear(List<Checkin> checkins) =>
      checkins.isEmpty ? DateTime.now().year : checkins.map((c) => c.date).reduce((a, b) => a.isBefore(b) ? a : b).year;

  static Map<String, dynamic> _keyResultToJson(KeyResult k) => {
    'id': k.id,
    'title': k.title,
    'type': k.type.name,
    'start': k.start,
    'value': k.value,
    'target': k.target,
    'unit': k.unit,
    'step': k.step,
    'milestones': [
      for (final m in k.milestones) {'title': m.title, 'isDone': m.isDone},
    ],
  };

  static KeyResult _keyResultFromJson(Map<String, dynamic> json) => KeyResult(
    id: json['id'] as String,
    title: json['title'] as String,
    type: KeyResultType.values.byName(json['type'] as String),
    start: (json['start'] as num).toDouble(),
    value: (json['value'] as num).toDouble(),
    target: (json['target'] as num).toDouble(),
    unit: json['unit'] as String,
    step: (json['step'] as num).toDouble(),
    milestones: [
      for (final m in json['milestones'] as List) Milestone(title: m['title'] as String, isDone: m['isDone'] as bool),
    ],
  );

  static Map<String, dynamic> _checkinToJson(Checkin c) => {
    'id': c.id,
    'date': c.date.toIso8601String(),
    'mood': c.mood?.name,
    'text': c.text,
    'change': c.change == null
        ? null
        : {
            'kind': c.change!.kind.name,
            'subject': c.change!.subject,
            'from': c.change!.from,
            'to': c.change!.to,
            'total': c.change!.total,
            'unit': c.change!.unit,
            'keyResultId': c.change!.keyResultId,
          },
  };

  static Checkin _checkinFromJson(Map<String, dynamic> json) {
    final change = json['change'] as Map<String, dynamic>?;
    final mood = json['mood'] as String?;
    return Checkin(
      id: json['id'] as String,
      date: DateTime.parse(json['date'] as String),
      mood: mood == null ? null : Mood.values.byName(mood),
      text: json['text'] as String? ?? '',
      change: change == null
          ? null
          : ProgressChange(
              kind: ProgressChangeKind.values.byName(change['kind'] as String),
              subject: change['subject'] as String,
              from: (change['from'] as num).toDouble(),
              to: (change['to'] as num).toDouble(),
              total: change['total'] as int,
              unit: change['unit'] as String,
              keyResultId: change['keyResultId'] as String? ?? '',
            ),
    );
  }
}
