import 'package:get_it/get_it.dart';
import 'package:path_provider/path_provider.dart';

import '../layers/functional/objectives/data/gateways/backup_gateway_impl.dart';
import '../layers/functional/objectives/domain/gateways/backup_gateway.dart';
import '../layers/functional/objectives/domain/use_cases/backup_use_cases.dart';
import '../layers/technical/files/file_exchange.dart';

import '../layers/functional/objectives/data/gateways/objective_preferences_gateway_impl.dart';
import '../layers/functional/objectives/domain/gateways/objective_preferences_gateway.dart';
import '../layers/functional/objectives/domain/use_cases/delete_checkin_use_case.dart';
import '../layers/functional/objectives/domain/use_cases/reorder_objectives_use_case.dart';
import '../layers/functional/objectives/domain/use_cases/restore_objective_use_case.dart';
import '../layers/functional/objectives/domain/use_cases/sort_objectives_use_case.dart';
import '../layers/functional/objectives/presentation/cubit/objectives_use_cases.dart';

import '../layers/functional/objectives/data/data_sources/objective_local_data_source.dart';
import '../layers/functional/objectives/data/gateways/objective_gateway_impl.dart';
import '../layers/functional/objectives/data/gateways/year_review_gateway_impl.dart';
import '../layers/functional/objectives/domain/gateways/objective_gateway.dart';
import '../layers/functional/objectives/domain/gateways/year_review_gateway.dart';
import '../layers/functional/objectives/domain/use_cases/add_checkin_use_case.dart';
import '../layers/functional/objectives/domain/use_cases/create_objective_use_case.dart';
import '../layers/functional/objectives/domain/use_cases/delete_objective_use_case.dart';
import '../layers/functional/objectives/domain/use_cases/get_active_year_use_case.dart';
import '../layers/functional/objectives/domain/use_cases/get_year_review_use_case.dart';
import '../layers/functional/objectives/domain/use_cases/save_year_review_use_case.dart';
import '../layers/functional/objectives/domain/use_cases/start_next_year_use_case.dart';
import '../layers/functional/objectives/domain/use_cases/toggle_milestone_use_case.dart';
import '../layers/functional/objectives/domain/use_cases/update_objective_use_case.dart';
import '../layers/functional/objectives/domain/use_cases/update_key_result_use_case.dart';
import '../layers/functional/objectives/domain/use_cases/watch_active_year_use_case.dart';
import '../layers/functional/objectives/domain/use_cases/watch_objectives_use_case.dart';
import '../layers/functional/profile/data/gateways/reminder_gateway_impl.dart';
import '../layers/functional/profile/data/gateways/settings_gateway_impl.dart';
import '../layers/functional/profile/domain/gateways/reminder_gateway.dart';
import '../layers/functional/profile/domain/gateways/settings_gateway.dart';
import '../layers/functional/profile/domain/use_cases/complete_onboarding_use_case.dart';
import '../layers/functional/profile/domain/use_cases/get_settings_use_case.dart';
import '../layers/functional/profile/domain/use_cases/schedule_checkin_reminders_use_case.dart';
import '../layers/functional/profile/domain/use_cases/update_settings_use_case.dart';
import '../layers/functional/profile/domain/use_cases/watch_reminder_taps_use_case.dart';
import '../layers/technical/clock/clock.dart';
import '../layers/technical/localization/app_language.dart';
import '../layers/technical/localization/app_locale.dart';
import '../layers/technical/notifications/local_notifications.dart';
import '../layers/technical/preferences/app_preferences.dart';

Future<void> initializeDependencies() async {
  final getIt = GetIt.instance;
  if (getIt.isRegistered<Clock>()) return;
  final notifications = LocalNotifications(
    () => NotificationTexts(
      title: AppLanguage.text(AppLocale.reminderNotificationTitle),
      body: AppLanguage.text(AppLocale.reminderNotificationBody),
      channelName: AppLanguage.text(AppLocale.reminderChannelName),
    ),
  );
  await notifications.initialize();
  getIt
    ..registerSingleton<Clock>(DateTime.now)
    ..registerSingleton<AppPreferences>(await AppPreferences.create())
    ..registerLazySingleton<ObjectiveGateway>(
      () => ObjectiveGatewayImpl(ObjectiveLocalDataSource(getApplicationDocumentsDirectory)),
    )
    ..registerLazySingleton<BackupGateway>(() => BackupGatewayImpl(getIt(), getIt(), getIt(), FileExchange(), getIt()))
    ..registerLazySingleton<ObjectivePreferencesGateway>(() => ObjectivePreferencesGatewayImpl(getIt()))
    ..registerLazySingleton<YearReviewGateway>(() => YearReviewGatewayImpl(getIt(), getIt()))
    ..registerLazySingleton<SettingsGateway>(() => SettingsGatewayImpl(getIt()))
    ..registerLazySingleton<ReminderGateway>(() => ReminderGatewayImpl(notifications));
  registerUseCases(getIt);
}

/// Use cases and their groupings, on top of whichever gateways are registered (real ones, or fakes in tests).
void registerUseCases(GetIt getIt) {
  getIt
    ..registerLazySingleton(() => ExportBackupUseCase(getIt()))
    ..registerLazySingleton(() => ImportBackupUseCase(getIt()))
    ..registerLazySingleton(() => WatchObjectivesUseCase(getIt()))
    ..registerLazySingleton(() => CreateObjectiveUseCase(getIt(), getIt()))
    ..registerLazySingleton(() => UpdateObjectiveUseCase(getIt()))
    ..registerLazySingleton(() => DeleteObjectiveUseCase(getIt()))
    ..registerLazySingleton(() => AddCheckinUseCase(getIt(), getIt()))
    ..registerLazySingleton(() => ToggleMilestoneUseCase(getIt(), getIt()))
    ..registerLazySingleton(() => UpdateKeyResultUseCase(getIt(), getIt()))
    ..registerLazySingleton(() => GetYearReviewUseCase(getIt()))
    ..registerLazySingleton(() => SaveYearReviewUseCase(getIt()))
    ..registerLazySingleton(() => GetActiveYearUseCase(getIt()))
    ..registerLazySingleton(() => DeleteCheckinUseCase(getIt()))
    ..registerLazySingleton(() => RestoreObjectiveUseCase(getIt()))
    ..registerLazySingleton(() => ReorderObjectivesUseCase(getIt()))
    ..registerLazySingleton(() => GetObjectiveSortUseCase(getIt()))
    ..registerLazySingleton(() => SetObjectiveSortUseCase(getIt()))
    ..registerLazySingleton(
      () => ObjectivesUseCases(
        watchObjectives: getIt(),
        watchActiveYear: getIt(),
        getActiveYear: getIt(),
        toggleMilestone: getIt(),
        updateKeyResult: getIt(),
        addCheckin: getIt(),
        deleteCheckin: getIt(),
        deleteObjective: getIt(),
        restoreObjective: getIt(),
        reorder: getIt(),
        getSort: getIt(),
        setSort: getIt(),
      ),
    )
    ..registerLazySingleton(() => WatchActiveYearUseCase(getIt()))
    ..registerLazySingleton(() => StartNextYearUseCase(getIt(), getIt(), getIt()))
    ..registerLazySingleton(() => GetSettingsUseCase(getIt()))
    ..registerLazySingleton(() => ScheduleCheckinRemindersUseCase(getIt(), getIt()))
    ..registerLazySingleton(() => CompleteOnboardingUseCase(getIt(), getIt(), getIt()))
    ..registerLazySingleton(() => UpdateSettingsUseCase(getIt(), getIt(), getIt()))
    ..registerLazySingleton(() => WatchReminderTapsUseCase(getIt()));
}
