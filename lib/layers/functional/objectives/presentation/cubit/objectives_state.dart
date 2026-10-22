import '../../domain/entities/objective.dart';

enum ObjectivesStatus { loading, ready, failure }

enum ObjectivesNotice {
  milestoneDone,
  progressSaved,
  checkinPublished,
  objectiveCreated,
  objectiveUpdated,
  objectiveDeleted,
  saveFailed,
}

class ObjectivesState {
  const ObjectivesState({
    required this.now,
    required this.activeYear,
    this.status = ObjectivesStatus.loading,
    this.allObjectives = const [],
    this.notice,
    this.noticeId = 0,
  });

  final DateTime now;
  final int activeYear;
  final ObjectivesStatus status;
  final List<Objective> allObjectives;
  final ObjectivesNotice? notice;
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
  }) => ObjectivesState(
    now: now ?? this.now,
    activeYear: activeYear ?? this.activeYear,
    status: status ?? this.status,
    allObjectives: allObjectives ?? this.allObjectives,
    notice: notice,
    noticeId: noticeId,
  );

  ObjectivesState withNotice(ObjectivesNotice notice) => ObjectivesState(
    now: now,
    activeYear: activeYear,
    status: status,
    allObjectives: allObjectives,
    notice: notice,
    noticeId: noticeId + 1,
  );
}
