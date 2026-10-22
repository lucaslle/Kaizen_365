import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/checkin.dart';
import '../../domain/entities/objective.dart';

class JournalFilter {
  const JournalFilter({this.objectiveId, this.query = '', this.queryRevision = 0});

  final String? objectiveId;
  final String query;
  final int queryRevision;

  bool matches(Checkin checkin, Objective objective) {
    if (objectiveId != null && objective.id != objectiveId) return false;
    final needle = query.trim().toLowerCase();
    if (needle.isEmpty) return true;
    return [checkin.text, objective.title, checkin.change?.subject ?? ''].any((t) => t.toLowerCase().contains(needle));
  }
}

class JournalFilterCubit extends Cubit<JournalFilter> {
  JournalFilterCubit() : super(const JournalFilter());

  void objectiveSelected(String? objectiveId) =>
      emit(JournalFilter(objectiveId: objectiveId, query: state.query, queryRevision: state.queryRevision));

  void queryChanged(String query) =>
      emit(JournalFilter(objectiveId: state.objectiveId, query: query, queryRevision: state.queryRevision));

  void queryCleared() => emit(JournalFilter(objectiveId: state.objectiveId, queryRevision: state.queryRevision + 1));
}
