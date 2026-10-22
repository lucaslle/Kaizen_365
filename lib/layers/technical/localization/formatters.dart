import 'package:intl/intl.dart';

abstract final class Formatters {
  static String get locale => Intl.defaultLocale ?? 'fr_FR';

  static String number(num value) => NumberFormat.decimalPattern(locale).format(value);

  static String percent(double ratio) => '${(ratio * 100).round()}%';

  static String shortDate(DateTime date) => DateFormat('d MMM', locale).format(date);

  static String monthName(DateTime date) => DateFormat.MMMM(locale).format(date);

  static String time(int minutes) => DateFormat.Hm(locale).format(DateTime(2000, 1, 1, minutes ~/ 60, minutes % 60));

  static String weekdayAndTime(DateTime date) => DateFormat('EEE d MMM · HH:mm', locale).format(date);

  static List<String> monthInitials(int year) => [
    for (var m = 1; m <= 12; m++) DateFormat('MMMMM', locale).format(DateTime(year, m)),
  ];
}
