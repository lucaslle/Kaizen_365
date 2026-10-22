import 'package:intl/intl.dart';

abstract final class Formatters {
  static const locale = 'fr_FR';

  static String number(num value) => NumberFormat.decimalPattern(locale).format(value);

  static String percent(double ratio) => '${(ratio * 100).round()}%';

  static String shortDate(DateTime date) => DateFormat('d MMM', locale).format(date);

  static String monthName(DateTime date) => DateFormat.MMMM(locale).format(date);

  static List<String> monthInitials(int year) => [
    for (var m = 1; m <= 12; m++) DateFormat('MMMMM', locale).format(DateTime(year, m)),
  ];
}
