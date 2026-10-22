abstract final class ReminderSchedule {
  static const hour = 18;
  static const biweeklyCount = 26;
  static final _referenceSunday = DateTime.utc(2023, 1, 1);

  static List<DateTime> nextBiweekly(DateTime now, {int count = biweeklyCount}) {
    final today = DateTime.utc(now.year, now.month, now.day);
    var sunday = today.add(Duration(days: (DateTime.sunday - today.weekday) % 7));
    final weeksFromReference = sunday.difference(_referenceSunday).inDays ~/ 7;
    if (weeksFromReference.isOdd) sunday = sunday.add(const Duration(days: 7));
    var first = DateTime(sunday.year, sunday.month, sunday.day, hour);
    if (!first.isAfter(now)) first = DateTime(first.year, first.month, first.day + 14, hour);
    return [for (var i = 0; i < count; i++) DateTime(first.year, first.month, first.day + 14 * i, hour)];
  }
}
