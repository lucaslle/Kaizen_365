import 'package:flutter_test/flutter_test.dart';
import 'package:kaizen365/layers/functional/profile/domain/entities/reminder_schedule.dart';
import 'package:kaizen365/layers/functional/profile/domain/entities/user_settings.dart';
import 'package:kaizen365/layers/functional/profile/domain/gateways/settings_gateway.dart';
import 'package:kaizen365/layers/functional/profile/domain/use_cases/complete_onboarding_use_case.dart';
import 'package:kaizen365/layers/functional/profile/domain/use_cases/schedule_checkin_reminders_use_case.dart';
import 'package:kaizen365/layers/functional/profile/domain/use_cases/update_settings_use_case.dart';

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
    await schedule(const UserSettings());
    expect(gateway.calls, ['cancelAll', 'weekly ${DateTime.sunday} 1080']);
    gateway.calls.clear();
    await schedule(const UserSettings(rhythm: CheckinRhythm.monthly, reminderMinutes: 8 * 60 + 30));
    expect(gateway.calls, ['cancelAll', 'monthly 1 510']);
    gateway.calls.clear();
    await schedule(const UserSettings(areRemindersEnabled: false));
    expect(gateway.calls, ['cancelAll']);
  });

  test('biweekly schedules a year of Sundays at 18:00, two weeks apart', () async {
    await schedule(const UserSettings(rhythm: CheckinRhythm.biweekly));
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
    final fromMonday = ReminderSchedule.nextBiweekly(DateTime(2026, 10, 12, 8), 1080);
    final fromThursday = ReminderSchedule.nextBiweekly(DateTime(2026, 10, 15, 8), 1080);
    expect(fromThursday.first, fromMonday.first);
    final onReminderEvening = ReminderSchedule.nextBiweekly(fromMonday.first.add(const Duration(hours: 1)), 1080);
    expect(onReminderEvening.first, fromMonday[1]);
  });

  test('completing onboarding schedules reminders only when notifications are allowed', () async {
    final settings = _NoopSettingsGateway();
    final complete = CompleteOnboardingUseCase(settings, gateway, schedule);
    gateway.isPermissionGranted = false;
    await complete(const UserSettings(name: ' Camille '));
    expect((settings.saved!.name, settings.saved!.areRemindersEnabled), ('Camille', false));
    expect(gateway.calls, ['cancelAll']);
    gateway.calls.clear();
    gateway.isPermissionGranted = true;
    await complete(const UserSettings(name: 'Camille'));
    expect(settings.saved!.areRemindersEnabled, isTrue);
    expect(gateway.calls, ['cancelAll', 'weekly ${DateTime.sunday} 1080']);
  });

  test('next reminder follows rhythm and time, and is null when reminders are off', () {
    final sunday = ReminderSchedule.next(now, const UserSettings(reminderMinutes: 20 * 60));
    expect(sunday, DateTime(2026, 10, 18, 20));
    expect(ReminderSchedule.next(now, const UserSettings(rhythm: CheckinRhythm.monthly)), DateTime(2026, 11, 1, 18));
    expect(ReminderSchedule.next(DateTime(2026, 10, 18, 19), const UserSettings()), DateTime(2026, 10, 25, 18));
    expect(ReminderSchedule.next(now, const UserSettings(areRemindersEnabled: false)), isNull);
  });

  test('changing settings reschedules, and switches reminders off when the permission is refused', () async {
    final settings = _NoopSettingsGateway();
    final update = UpdateSettingsUseCase(settings, gateway, schedule);
    const before = UserSettings(hasCompletedOnboarding: true);
    await update(before, before.copyWith(name: 'Lucas'));
    expect(gateway.calls, isEmpty);
    await update(before, before.copyWith(reminderMinutes: 7 * 60));
    expect(gateway.calls, ['cancelAll', 'weekly ${DateTime.sunday} 420']);
    gateway
      ..calls.clear()
      ..isPermissionGranted = false;
    final saved = await update(before, before.copyWith(rhythm: CheckinRhythm.monthly));
    expect(saved.areRemindersEnabled, isFalse);
    expect(settings.saved!.areRemindersEnabled, isFalse);
    expect(gateway.calls, ['cancelAll']);
  });
}
