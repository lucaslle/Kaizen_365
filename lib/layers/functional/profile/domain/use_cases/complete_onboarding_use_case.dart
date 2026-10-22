import '../entities/user_settings.dart';
import '../gateways/reminder_gateway.dart';
import '../gateways/settings_gateway.dart';
import 'schedule_checkin_reminders_use_case.dart';

class CompleteOnboardingUseCase {
  CompleteOnboardingUseCase(this._settingsGateway, this._reminderGateway, this._scheduleReminders);

  final SettingsGateway _settingsGateway;
  final ReminderGateway _reminderGateway;
  final ScheduleCheckinRemindersUseCase _scheduleReminders;

  Future<UserSettings> call(UserSettings draft) async {
    final isAllowed = await _reminderGateway.requestPermission();
    final settings = draft.copyWith(
      name: draft.name.trim(),
      hasCompletedOnboarding: true,
      areRemindersEnabled: isAllowed,
    );
    await _settingsGateway.save(settings);
    await _scheduleReminders(settings);
    return settings;
  }
}
