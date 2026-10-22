import '../../../../technical/clock/clock.dart';
import '../entities/reminder_schedule.dart';
import '../entities/user_settings.dart';
import '../gateways/reminder_gateway.dart';

class ScheduleCheckinRemindersUseCase {
  ScheduleCheckinRemindersUseCase(this._gateway, this._clock);

  final ReminderGateway _gateway;
  final Clock _clock;

  Future<void> call(CheckinRhythm rhythm) async {
    await _gateway.cancelAll();
    switch (rhythm) {
      case CheckinRhythm.weekly:
        await _gateway.scheduleWeekly(weekday: DateTime.sunday, hour: ReminderSchedule.hour);
      case CheckinRhythm.monthly:
        await _gateway.scheduleMonthly(day: 1, hour: ReminderSchedule.hour);
      case CheckinRhythm.biweekly:
        for (final (i, at) in ReminderSchedule.nextBiweekly(_clock()).indexed) {
          await _gateway.scheduleOnce(id: i + 1, at: at);
        }
    }
  }
}
