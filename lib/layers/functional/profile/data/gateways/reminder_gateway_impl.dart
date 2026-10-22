import '../../../../technical/notifications/local_notifications.dart';
import '../../domain/gateways/reminder_gateway.dart';

class ReminderGatewayImpl implements ReminderGateway {
  ReminderGatewayImpl(this._notifications);

  final LocalNotifications _notifications;

  @override
  Future<bool> requestPermission() => _notifications.requestPermission();

  @override
  Future<void> cancelAll() => _notifications.cancelAll();

  @override
  Future<void> scheduleWeekly({required int weekday, required int minutes}) =>
      _notifications.scheduleWeekly(weekday: weekday, minutes: minutes);

  @override
  Future<void> scheduleMonthly({required int day, required int minutes}) =>
      _notifications.scheduleMonthly(day: day, minutes: minutes);

  @override
  Future<void> scheduleOnce({required int id, required DateTime at}) => _notifications.scheduleOnce(id: id, at: at);

  @override
  Stream<void> watchReminderTaps() => _notifications.watchTaps();
}
