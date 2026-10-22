import '../../../../technical/clock/clock.dart';
import '../entities/reminder_schedule.dart';
import '../entities/user_settings.dart';
import '../gateways/reminder_gateway.dart';

class ScheduleCheckinRemindersUseCase {
  ScheduleCheckinRemindersUseCase(this._gateway, this._clock);

  final ReminderGateway _gateway;
  final Clock _clock;

  Future<void> call(UserSettings settings) async {
    await _gateway.cancelAll();
    if (!settings.areRemindersEnabled) return;
    final minutes = settings.reminderMinutes;
    switch (settings.rhythm) {
      case CheckinRhythm.weekly:
        await _gateway.scheduleWeekly(weekday: DateTime.sunday, minutes: minutes);
      case CheckinRhythm.monthly:
        await _gateway.scheduleMonthly(day: 1, minutes: minutes);
      case CheckinRhythm.biweekly:
        for (final (i, at) in ReminderSchedule.nextBiweekly(_clock(), minutes).indexed) {
          await _gateway.scheduleOnce(id: i + 1, at: at);
        }
    }
  }
}
