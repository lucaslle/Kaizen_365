import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

class NotificationTexts {
  const NotificationTexts({required this.title, required this.body, required this.channelName});

  final String title;
  final String body;
  final String channelName;
}

class LocalNotifications {
  LocalNotifications(this._texts);

  static const _weeklyId = 100;
  static const _monthlyId = 101;

  final NotificationTexts _texts;
  final _plugin = FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    tz_data.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation((await FlutterTimezone.getLocalTimezone()).identifier));
    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('ic_notification'),
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      ),
    );
  }

  Future<bool> requestPermission() async {
    final android = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    final ios = _plugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
    return await android?.requestNotificationsPermission() ??
        await ios?.requestPermissions(alert: true, sound: true) ??
        false;
  }

  Future<void> cancelAll() => _plugin.cancelAll();

  Future<void> scheduleWeekly({required int weekday, required int hour}) {
    var at = _todayAt(hour);
    while (at.weekday != weekday || !at.isAfter(tz.TZDateTime.now(tz.local))) {
      at = tz.TZDateTime(tz.local, at.year, at.month, at.day + 1, hour);
    }
    return _schedule(_weeklyId, at, DateTimeComponents.dayOfWeekAndTime);
  }

  Future<void> scheduleMonthly({required int day, required int hour}) {
    final now = tz.TZDateTime.now(tz.local);
    var at = tz.TZDateTime(tz.local, now.year, now.month, day, hour);
    if (!at.isAfter(now)) at = tz.TZDateTime(tz.local, now.year, now.month + 1, day, hour);
    return _schedule(_monthlyId, at, DateTimeComponents.dayOfMonthAndTime);
  }

  Future<void> scheduleOnce({required int id, required DateTime at}) =>
      _schedule(id, tz.TZDateTime(tz.local, at.year, at.month, at.day, at.hour, at.minute), null);

  tz.TZDateTime _todayAt(int hour) {
    final now = tz.TZDateTime.now(tz.local);
    return tz.TZDateTime(tz.local, now.year, now.month, now.day, hour);
  }

  Future<void> _schedule(int id, tz.TZDateTime at, DateTimeComponents? repeat) => _plugin.zonedSchedule(
        id: id,
        scheduledDate: at,
        title: _texts.title,
        body: _texts.body,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: repeat,
        notificationDetails: NotificationDetails(
          android: AndroidNotificationDetails('checkin_reminders', _texts.channelName),
          iOS: const DarwinNotificationDetails(),
        ),
      );
}
