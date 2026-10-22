import 'objective.dart';
import 'progress.dart';

enum ObjectiveSort { manual, status, progress }

List<Objective> sortObjectives(List<Objective> objectives, ObjectiveSort sort, double expected) {
  double gap(Objective o) => objectiveProgress(o) - expected;
  return switch (sort) {
    ObjectiveSort.manual => objectives,
    ObjectiveSort.status => [...objectives]..sort((a, b) => gap(a).compareTo(gap(b))),
    ObjectiveSort.progress => [...objectives]..sort((a, b) => objectiveProgress(b).compareTo(objectiveProgress(a))),
  };
}
