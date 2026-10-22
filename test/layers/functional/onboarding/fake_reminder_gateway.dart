import 'package:kaizen365/layers/functional/onboarding/domain/gateways/reminder_gateway.dart';

class FakeReminderGateway implements ReminderGateway {
  bool isPermissionGranted = true;
  final calls = <String>[];
  final onceDates = <DateTime>[];

  @override
  Future<bool> requestPermission() async => isPermissionGranted;

  @override
  Future<void> cancelAll() async => calls.add('cancelAll');

  @override
  Future<void> scheduleWeekly({required int weekday, required int hour}) async => calls.add('weekly $weekday $hour');

  @override
  Future<void> scheduleMonthly({required int day, required int hour}) async => calls.add('monthly $day $hour');

  @override
  Future<void> scheduleOnce({required int id, required DateTime at}) async {
    calls.add('once $id');
    onceDates.add(at);
  }
}
