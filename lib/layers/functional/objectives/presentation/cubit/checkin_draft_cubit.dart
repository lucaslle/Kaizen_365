import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/mood.dart';

class CheckinDraft {
  const CheckinDraft({this.mood = Mood.up, this.text = ''});

  final Mood mood;
  final String text;

  bool get canPublish => text.trim().isNotEmpty;
}

class CheckinDraftCubit extends Cubit<CheckinDraft> {
  CheckinDraftCubit() : super(const CheckinDraft());

  void moodSelected(Mood mood) => emit(CheckinDraft(mood: mood, text: state.text));

  void textChanged(String text) => emit(CheckinDraft(mood: state.mood, text: text));
}
