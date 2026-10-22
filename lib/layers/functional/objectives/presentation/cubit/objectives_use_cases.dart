import '../../domain/use_cases/add_checkin_use_case.dart';
import '../../domain/use_cases/delete_checkin_use_case.dart';
import '../../domain/use_cases/delete_objective_use_case.dart';
import '../../domain/use_cases/get_active_year_use_case.dart';
import '../../domain/use_cases/reorder_objectives_use_case.dart';
import '../../domain/use_cases/restore_objective_use_case.dart';
import '../../domain/use_cases/sort_objectives_use_case.dart';
import '../../domain/use_cases/toggle_milestone_use_case.dart';
import '../../domain/use_cases/update_key_result_use_case.dart';
import '../../domain/use_cases/watch_active_year_use_case.dart';
import '../../domain/use_cases/watch_objectives_use_case.dart';

/// The actions the objectives screens can trigger, grouped so the cubit takes one dependency.
class ObjectivesUseCases {
  const ObjectivesUseCases({
    required this.watchObjectives,
    required this.watchActiveYear,
    required this.getActiveYear,
    required this.toggleMilestone,
    required this.updateKeyResult,
    required this.addCheckin,
    required this.deleteCheckin,
    required this.deleteObjective,
    required this.restoreObjective,
    required this.reorder,
    required this.getSort,
    required this.setSort,
  });

  final WatchObjectivesUseCase watchObjectives;
  final WatchActiveYearUseCase watchActiveYear;
  final GetActiveYearUseCase getActiveYear;
  final ToggleMilestoneUseCase toggleMilestone;
  final UpdateKeyResultUseCase updateKeyResult;
  final AddCheckinUseCase addCheckin;
  final DeleteCheckinUseCase deleteCheckin;
  final DeleteObjectiveUseCase deleteObjective;
  final RestoreObjectiveUseCase restoreObjective;
  final ReorderObjectivesUseCase reorder;
  final GetObjectiveSortUseCase getSort;
  final SetObjectiveSortUseCase setSort;
}
