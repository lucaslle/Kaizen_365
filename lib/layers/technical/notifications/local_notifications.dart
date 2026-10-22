import 'dart:async';

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

  /// Resolved when scheduling, so the reminders follow the current language.
  final NotificationTexts Function() _texts;
  final _plugin = FlutterLocalNotificationsPlugin();
  final _taps = StreamController<void>.broadcast();
  bool _wasLaunchedFromNotification = false;

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
      onDidReceiveNotificationResponse: (_) => _taps.add(null),
    );
    final launch = await _plugin.getNotificationAppLaunchDetails();
    _wasLaunchedFromNotification = launch?.didNotificationLaunchApp ?? false;
  }

  /// Taps on a reminder, including the one that launched the app.
  Stream<void> watchTaps() async* {
    if (_wasLaunchedFromNotification) {
      _wasLaunchedFromNotification = false;
      yield null;
    }
    yield* _taps.stream;
  }

  Future<bool> requestPermission() async {
    final android = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    final ios = _plugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
    return await android?.requestNotificationsPermission() ??
        await ios?.requestPermissions(alert: true, sound: true) ??
        false;
  }

  Future<void> cancelAll() => _plugin.cancelAll();

  Future<void> scheduleWeekly({required int weekday, required int minutes}) {
    final now = tz.TZDateTime.now(tz.local);
    var at = _at(now.year, now.month, now.day, minutes);
    while (at.weekday != weekday || !at.isAfter(now)) {
      at = _at(at.year, at.month, at.day + 1, minutes);
    }
    return _schedule(_weeklyId, at, DateTimeComponents.dayOfWeekAndTime);
  }

  Future<void> scheduleMonthly({required int day, required int minutes}) {
    final now = tz.TZDateTime.now(tz.local);
    var at = _at(now.year, now.month, day, minutes);
    if (!at.isAfter(now)) at = _at(now.year, now.month + 1, day, minutes);
    return _schedule(_monthlyId, at, DateTimeComponents.dayOfMonthAndTime);
  }

  Future<void> scheduleOnce({required int id, required DateTime at}) =>
      _schedule(id, tz.TZDateTime(tz.local, at.year, at.month, at.day, at.hour, at.minute), null);

  tz.TZDateTime _at(int year, int month, int day, int minutes) =>
      tz.TZDateTime(tz.local, year, month, day, minutes ~/ 60, minutes % 60);

  Future<void> _schedule(int id, tz.TZDateTime at, DateTimeComponents? repeat) {
    final texts = _texts();
    return _plugin.zonedSchedule(
      id: id,
      scheduledDate: at,
      title: texts.title,
      body: texts.body,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: repeat,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails('checkin_reminders', texts.channelName),
        iOS: const DarwinNotificationDetails(),
      ),
    );
  }
}
