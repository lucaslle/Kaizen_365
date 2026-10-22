import 'package:get_it/get_it.dart';
import 'package:path_provider/path_provider.dart';

import '../layers/functional/objectives/data/data_sources/objective_local_data_source.dart';
import '../layers/functional/objectives/data/gateways/objective_gateway_impl.dart';
import '../layers/functional/objectives/data/gateways/year_review_gateway_impl.dart';
import '../layers/functional/objectives/domain/gateways/objective_gateway.dart';
import '../layers/functional/objectives/domain/gateways/year_review_gateway.dart';
import '../layers/functional/objectives/domain/use_cases/add_checkin_use_case.dart';
import '../layers/functional/objectives/domain/use_cases/create_objective_use_case.dart';
import '../layers/functional/objectives/domain/use_cases/get_year_review_use_case.dart';
import '../layers/functional/objectives/domain/use_cases/save_year_review_use_case.dart';
import '../layers/functional/objectives/domain/use_cases/toggle_milestone_use_case.dart';
import '../layers/functional/objectives/domain/use_cases/update_key_result_use_case.dart';
import '../layers/functional/objectives/domain/use_cases/watch_objectives_use_case.dart';
import '../layers/functional/onboarding/data/gateways/reminder_gateway_impl.dart';
import '../layers/functional/onboarding/data/gateways/settings_gateway_impl.dart';
import '../layers/functional/onboarding/domain/gateways/reminder_gateway.dart';
import '../layers/functional/onboarding/domain/gateways/settings_gateway.dart';
import '../layers/functional/onboarding/domain/use_cases/complete_onboarding_use_case.dart';
import '../layers/functional/onboarding/domain/use_cases/get_settings_use_case.dart';
import '../layers/functional/onboarding/domain/use_cases/schedule_checkin_reminders_use_case.dart';
import '../layers/technical/clock/clock.dart';
import '../layers/technical/localization/app_locale.dart';
import '../layers/technical/notifications/local_notifications.dart';
import '../layers/technical/preferences/app_preferences.dart';

Future<void> initializeDependencies() async {
  final getIt = GetIt.instance;
  if (getIt.isRegistered<Clock>()) return;
  final notifications = LocalNotifications(
    NotificationTexts(
      title: AppLocale.fr[AppLocale.reminderNotificationTitle] as String,
      body: AppLocale.fr[AppLocale.reminderNotificationBody] as String,
      channelName: AppLocale.fr[AppLocale.reminderChannelName] as String,
    ),
  );
  await notifications.initialize();
  getIt
    ..registerSingleton<Clock>(DateTime.now)
    ..registerSingleton<AppPreferences>(await AppPreferences.create())
    ..registerLazySingleton<ObjectiveGateway>(
      () => ObjectiveGatewayImpl(ObjectiveLocalDataSource(getApplicationDocumentsDirectory)),
    )
    ..registerLazySingleton<YearReviewGateway>(() => YearReviewGatewayImpl(getIt()))
    ..registerLazySingleton<SettingsGateway>(() => SettingsGatewayImpl(getIt()))
    ..registerLazySingleton<ReminderGateway>(() => ReminderGatewayImpl(notifications))
    ..registerLazySingleton(() => WatchObjectivesUseCase(getIt()))
    ..registerLazySingleton(() => CreateObjectiveUseCase(getIt(), getIt()))
    ..registerLazySingleton(() => AddCheckinUseCase(getIt(), getIt()))
    ..registerLazySingleton(() => ToggleMilestoneUseCase(getIt(), getIt()))
    ..registerLazySingleton(() => UpdateKeyResultUseCase(getIt(), getIt()))
    ..registerLazySingleton(() => GetYearReviewUseCase(getIt()))
    ..registerLazySingleton(() => SaveYearReviewUseCase(getIt()))
    ..registerLazySingleton(() => GetSettingsUseCase(getIt()))
    ..registerLazySingleton(() => ScheduleCheckinRemindersUseCase(getIt(), getIt()))
    ..registerLazySingleton(() => CompleteOnboardingUseCase(getIt(), getIt(), getIt()));
}
