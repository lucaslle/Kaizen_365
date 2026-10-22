import 'package:flutter_test/flutter_test.dart';
import 'package:kaizen365/layers/functional/profile/domain/entities/reminder_schedule.dart';
import 'package:kaizen365/layers/functional/profile/domain/entities/user_settings.dart';
import 'package:kaizen365/layers/functional/profile/domain/gateways/settings_gateway.dart';
import 'package:kaizen365/layers/functional/profile/domain/use_cases/complete_onboarding_use_case.dart';
import 'package:kaizen365/layers/functional/profile/domain/use_cases/schedule_checkin_reminders_use_case.dart';

import 'fake_reminder_gateway.dart';

class _NoopSettingsGateway implements SettingsGateway {
  UserSettings? saved;

  @override
  UserSettings load() => const UserSettings();

  @override
  Future<void> save(UserSettings settings) async => saved = settings;
}

void main() {
  final now = DateTime(2026, 10, 13, 9);
  late FakeReminderGateway gateway;
  late ScheduleCheckinRemindersUseCase schedule;

  setUp(() {
    gateway = FakeReminderGateway();
    schedule = ScheduleCheckinRemindersUseCase(gateway, () => now);
  });

  test('weekly and monthly rhythms use a single repeating reminder', () async {
    await schedule(CheckinRhythm.weekly);
    expect(gateway.calls, ['cancelAll', 'weekly ${DateTime.sunday} 18']);
    gateway.calls.clear();
    await schedule(CheckinRhythm.monthly);
    expect(gateway.calls, ['cancelAll', 'monthly 1 18']);
  });

  test('biweekly schedules a year of Sundays at 18:00, two weeks apart', () async {
    await schedule(CheckinRhythm.biweekly);
    final dates = gateway.onceDates;
    expect(dates, hasLength(ReminderSchedule.biweeklyCount));
    expect(dates.first.isAfter(now), isTrue);
    expect(dates.first.difference(now).inDays, lessThan(14));
    for (final d in dates) {
      expect((d.weekday, d.hour, d.minute), (DateTime.sunday, 18, 0));
    }
    for (var i = 1; i < dates.length; i++) {
      expect(
        DateTime.utc(
          dates[i].year,
          dates[i].month,
          dates[i].day,
        ).difference(DateTime.utc(dates[i - 1].year, dates[i - 1].month, dates[i - 1].day)).inDays,
        14,
      );
    }
  });

  test('biweekly parity stays stable whatever the launch day', () {
    final fromMonday = ReminderSchedule.nextBiweekly(DateTime(2026, 10, 12, 8));
    final fromThursday = ReminderSchedule.nextBiweekly(DateTime(2026, 10, 15, 8));
    expect(fromThursday.first, fromMonday.first);
    final onReminderEvening = ReminderSchedule.nextBiweekly(fromMonday.first.add(const Duration(hours: 1)));
    expect(onReminderEvening.first, fromMonday[1]);
  });

  test('completing onboarding schedules reminders only when notifications are allowed', () async {
    final settings = _NoopSettingsGateway();
    final complete = CompleteOnboardingUseCase(settings, gateway, schedule);
    gateway.isPermissionGranted = false;
    await complete(const UserSettings(name: ' Camille '));
    expect(settings.saved!.name, 'Camille');
    expect(gateway.calls, isEmpty);
    gateway.isPermissionGranted = true;
    await complete(const UserSettings(name: 'Camille'));
    expect(gateway.calls, isNotEmpty);
  });
}
