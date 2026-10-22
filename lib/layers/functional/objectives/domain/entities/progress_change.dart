enum ProgressChangeKind { created, value, percent, milestones, milestoneDone }

class ProgressChange {
  const ProgressChange({
    required this.kind,
    this.subject = '',
    this.from = 0,
    this.to = 0,
    this.total = 0,
    this.unit = '',
  });

  final ProgressChangeKind kind;
  final String subject;
  final double from;
  final double to;
  final int total;
  final String unit;
}
