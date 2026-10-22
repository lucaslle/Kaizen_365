class Milestone {
  const Milestone({required this.title, this.isDone = false});

  final String title;
  final bool isDone;

  Milestone toggled() => Milestone(title: title, isDone: !isDone);
}
