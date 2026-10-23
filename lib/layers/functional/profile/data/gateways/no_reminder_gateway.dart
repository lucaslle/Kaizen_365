import '../../domain/gateways/reminder_gateway.dart';

/// Used where scheduled notifications do not exist, such as the web demo: reminders stay off.
class NoReminderGateway implements ReminderGateway {
  @override
  Future<bool> requestPermission() async => false;

  @override
  Future<void> cancelAll() async {}

  @override
  Future<void> scheduleWeekly({required int weekday, required int minutes}) async {}

  @override
  Future<void> scheduleMonthly({required int day, required int minutes}) async {}

  @override
  Future<void> scheduleOnce({required int id, required DateTime at}) async {}

  @override
  Stream<void> watchReminderTaps() => const Stream.empty();
}
