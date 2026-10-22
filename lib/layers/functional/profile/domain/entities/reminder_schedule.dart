import 'user_settings.dart';

abstract final class ReminderSchedule {
  static const biweeklyCount = 26;
  static final _referenceSunday = DateTime.utc(2023, 1, 1);

  /// Next [count] Sundays of even weeks (counted from a fixed reference Sunday) at [minutes] after midnight.
  static List<DateTime> nextBiweekly(DateTime now, int minutes, {int count = biweeklyCount}) {
    final today = DateTime.utc(now.year, now.month, now.day);
    var sunday = today.add(Duration(days: (DateTime.sunday - today.weekday) % 7));
    final weeksFromReference = sunday.difference(_referenceSunday).inDays ~/ 7;
    if (weeksFromReference.isOdd) sunday = sunday.add(const Duration(days: 7));
    var first = _at(sunday.year, sunday.month, sunday.day, minutes);
    if (!first.isAfter(now)) first = _at(first.year, first.month, first.day + 14, minutes);
    return [for (var i = 0; i < count; i++) _at(first.year, first.month, first.day + 14 * i, minutes)];
  }

  /// When the next check-in reminder fires, or null when reminders are off.
  static DateTime? next(DateTime now, UserSettings settings) {
    if (!settings.areRemindersEnabled) return null;
    final minutes = settings.reminderMinutes;
    switch (settings.rhythm) {
      case CheckinRhythm.biweekly:
        return nextBiweekly(now, minutes, count: 1).single;
      case CheckinRhythm.weekly:
        var day = _at(now.year, now.month, now.day, minutes);
        while (day.weekday != DateTime.sunday || !day.isAfter(now)) {
          day = _at(day.year, day.month, day.day + 1, minutes);
        }
        return day;
      case CheckinRhythm.monthly:
        final thisMonth = _at(now.year, now.month, 1, minutes);
        return thisMonth.isAfter(now) ? thisMonth : _at(now.year, now.month + 1, 1, minutes);
    }
  }

  static DateTime _at(int year, int month, int day, int minutes) =>
      DateTime(year, month, day, minutes ~/ 60, minutes % 60);
}
