import '../../domain/entities/objective.dart';
import '../../domain/entities/objective_sort.dart';

enum ObjectivesStatus { loading, ready, failure }

enum ObjectivesNotice {
  milestoneDone,
  progressSaved,
  checkinPublished,
  checkinDeleted,
  objectiveCreated,
  objectiveUpdated,
  objectiveDeleted,
  objectiveAchieved,
  saveFailed,
}

class ObjectivesState {
  const ObjectivesState({
    required this.now,
    required this.activeYear,
    this.status = ObjectivesStatus.loading,
    this.allObjectives = const [],
    this.sort = ObjectiveSort.manual,
    this.notice,
    this.noticeSubject = '',
    this.noticeId = 0,
  });

  final DateTime now;
  final int activeYear;
  final ObjectivesStatus status;
  final List<Objective> allObjectives;
  final ObjectiveSort sort;
  final ObjectivesNotice? notice;

  /// The objective a notice is about, such as the one just achieved.
  final String noticeSubject;
  final int noticeId;

  List<Objective> get objectives => [
    for (final o in allObjectives)
      if (o.year == activeYear) o,
  ];

  Objective? byId(String id) {
    for (final o in allObjectives) {
      if (o.id == id) return o;
    }
    return null;
  }

  ObjectivesState copyWith({
    DateTime? now,
    int? activeYear,
    ObjectivesStatus? status,
    List<Objective>? allObjectives,
    ObjectiveSort? sort,
  }) => ObjectivesState(
    now: now ?? this.now,
    activeYear: activeYear ?? this.activeYear,
    status: status ?? this.status,
    allObjectives: allObjectives ?? this.allObjectives,
    sort: sort ?? this.sort,
    notice: notice,
    noticeSubject: noticeSubject,
    noticeId: noticeId,
  );

  ObjectivesState withNotice(ObjectivesNotice notice, {String subject = ''}) => ObjectivesState(
    now: now,
    activeYear: activeYear,
    status: status,
    allObjectives: allObjectives,
    sort: sort,
    notice: notice,
    noticeSubject: subject,
    noticeId: noticeId + 1,
  );
}
