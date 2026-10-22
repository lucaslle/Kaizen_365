import '../entities/user_settings.dart';
import '../gateways/reminder_gateway.dart';
import '../gateways/settings_gateway.dart';
import 'schedule_checkin_reminders_use_case.dart';

class UpdateSettingsUseCase {
  UpdateSettingsUseCase(this._settingsGateway, this._reminderGateway, this._scheduleReminders);

  final SettingsGateway _settingsGateway;
  final ReminderGateway _reminderGateway;
  final ScheduleCheckinRemindersUseCase _scheduleReminders;

  /// Saves [next] and reschedules reminders when needed. Reminders are switched off when the permission is refused.
  Future<UserSettings> call(UserSettings previous, UserSettings next) async {
    var saved = next;
    if (next.remindsDifferentlyFrom(previous)) {
      final turnedOn = next.areRemindersEnabled && !previous.areRemindersEnabled;
      if (next.areRemindersEnabled && (turnedOn || next.rhythm != previous.rhythm)) {
        if (!await _reminderGateway.requestPermission()) saved = next.copyWith(areRemindersEnabled: false);
      }
      await _scheduleReminders(saved);
    }
    await _settingsGateway.save(saved);
    return saved;
  }
}
