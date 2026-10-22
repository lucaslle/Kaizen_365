import '../../domain/entities/objective.dart';

enum ObjectivesStatus { loading, ready, failure }

enum ObjectivesNotice { milestoneDone, progressSaved, checkinPublished, objectiveCreated, saveFailed }

class ObjectivesState {
  const ObjectivesState({
    required this.now,
    this.status = ObjectivesStatus.loading,
    this.objectives = const [],
    this.notice,
    this.noticeId = 0,
  });

  final DateTime now;
  final ObjectivesStatus status;
  final List<Objective> objectives;
  final ObjectivesNotice? notice;
  final int noticeId;

  Objective? byId(String id) {
    for (final o in objectives) {
      if (o.id == id) return o;
    }
    return null;
  }

  ObjectivesState copyWith({DateTime? now, ObjectivesStatus? status, List<Objective>? objectives}) => ObjectivesState(
        now: now ?? this.now,
        status: status ?? this.status,
        objectives: objectives ?? this.objectives,
        notice: notice,
        noticeId: noticeId,
      );

  ObjectivesState withNotice(ObjectivesNotice notice) => ObjectivesState(
        now: now,
        status: status,
        objectives: objectives,
        notice: notice,
        noticeId: noticeId + 1,
      );
}
