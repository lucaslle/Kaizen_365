import 'mood.dart';
import 'progress_change.dart';

class Checkin {
  const Checkin({
    required this.id,
    required this.date,
    this.mood,
    this.text = '',
    this.change,
  });

  final String id;
  final DateTime date;
  final Mood? mood;
  final String text;
  final ProgressChange? change;
}
