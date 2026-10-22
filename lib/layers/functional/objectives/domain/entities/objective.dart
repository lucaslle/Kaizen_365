import 'checkin.dart';
import 'key_result.dart';
import 'life_domain.dart';

class Objective {
  const Objective({
    required this.id,
    required this.title,
    required this.domain,
    required this.year,
    this.why = '',
    this.keyResults = const [],
    this.checkins = const [],
  });

  final String id;
  final String title;
  final LifeDomain domain;
  final int year;
  final String why;
  final List<KeyResult> keyResults;
  final List<Checkin> checkins;

  Objective copyWith({
    String? title,
    LifeDomain? domain,
    int? year,
    String? why,
    List<KeyResult>? keyResults,
    List<Checkin>? checkins,
  }) => Objective(
    id: id,
    title: title ?? this.title,
    domain: domain ?? this.domain,
    year: year ?? this.year,
    why: why ?? this.why,
    keyResults: keyResults ?? this.keyResults,
    checkins: checkins ?? this.checkins,
  );

  Objective withCheckin(Checkin checkin) => copyWith(checkins: [checkin, ...checkins]);

  Objective replacingKeyResult(KeyResult keyResult) =>
      copyWith(keyResults: [for (final k in keyResults) k.id == keyResult.id ? keyResult : k]);
}
