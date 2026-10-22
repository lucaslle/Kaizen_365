import 'package:flutter_bloc/flutter_bloc.dart';

class JournalFilterCubit extends Cubit<String?> {
  JournalFilterCubit() : super(null);

  void objectiveSelected(String? objectiveId) => emit(objectiveId);
}
