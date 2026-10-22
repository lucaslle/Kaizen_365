import '../entities/user_settings.dart';
import '../gateways/reminder_gateway.dart';
import '../gateways/settings_gateway.dart';
import 'schedule_checkin_reminders_use_case.dart';

class UpdateSettingsUseCase {
  UpdateSettingsUseCase(this._settingsGateway, this._reminderGateway, this._scheduleReminders);

  final SettingsGateway _settingsGateway;
  final ReminderGateway _reminderGateway;
  final ScheduleCheckinRemindersUseCase _scheduleReminders;

  Future<void> call(UserSettings previous, UserSettings next) async {
    await _settingsGateway.save(next);
    if (next.rhythm != previous.rhythm && await _reminderGateway.requestPermission()) {
      await _scheduleReminders(next.rhythm);
    }
  }
}
