import 'dart:async';

import 'package:kaizen365/layers/functional/profile/domain/gateways/reminder_gateway.dart';

class FakeReminderGateway implements ReminderGateway {
  bool isPermissionGranted = true;
  final calls = <String>[];
  final onceDates = <DateTime>[];
  final taps = StreamController<void>.broadcast();

  @override
  Future<bool> requestPermission() async => isPermissionGranted;

  @override
  Future<void> cancelAll() async => calls.add('cancelAll');

  @override
  Future<void> scheduleWeekly({required int weekday, required int minutes}) async =>
      calls.add('weekly $weekday $minutes');

  @override
  Future<void> scheduleMonthly({required int day, required int minutes}) async => calls.add('monthly $day $minutes');

  @override
  Future<void> scheduleOnce({required int id, required DateTime at}) async {
    calls.add('once $id');
    onceDates.add(at);
  }

  @override
  Stream<void> watchReminderTaps() => taps.stream;
}
