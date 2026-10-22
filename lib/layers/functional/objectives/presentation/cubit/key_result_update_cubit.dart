import 'dart:math';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/key_result.dart';
import '../../domain/entities/milestone.dart';

class KeyResultUpdateState {
  const KeyResultUpdateState({
    required this.value,
    required this.milestones,
    this.valueRevision = 0,
    this.newMilestone = '',
    this.milestoneRevision = 0,
    this.note = '',
  });

  final double value;
  final List<Milestone> milestones;
  final int valueRevision;
  final String newMilestone;
  final int milestoneRevision;
  final String note;

  KeyResultUpdateState copyWith({
    double? value,
    List<Milestone>? milestones,
    int? valueRevision,
    String? newMilestone,
    int? milestoneRevision,
    String? note,
  }) =>
      KeyResultUpdateState(
        value: value ?? this.value,
        milestones: milestones ?? this.milestones,
        valueRevision: valueRevision ?? this.valueRevision,
        newMilestone: newMilestone ?? this.newMilestone,
        milestoneRevision: milestoneRevision ?? this.milestoneRevision,
        note: note ?? this.note,
      );
}

class KeyResultUpdateCubit extends Cubit<KeyResultUpdateState> {
  KeyResultUpdateCubit(this.keyResult)
      : super(KeyResultUpdateState(value: keyResult.value, milestones: List.unmodifiable(keyResult.milestones)));

  final KeyResult keyResult;

  KeyResult get preview => keyResult.copyWith(value: state.value, milestones: state.milestones);

  void valueChanged(String text) =>
      emit(state.copyWith(value: double.tryParse(text.replaceAll(',', '.').replaceAll(RegExp(r'\s'), '')) ?? 0));

  void percentChanged(double value) => emit(state.copyWith(value: value));

  void decrement() => emit(state.copyWith(
        value: max(keyResult.start, state.value - keyResult.step),
        valueRevision: state.valueRevision + 1,
      ));

  void increment() => emit(state.copyWith(value: state.value + keyResult.step, valueRevision: state.valueRevision + 1));

  void toggleMilestone(int index) => emit(state.copyWith(
        milestones: List.unmodifiable([...state.milestones]..[index] = state.milestones[index].toggled()),
      ));

  void newMilestoneChanged(String text) => emit(state.copyWith(newMilestone: text));

  void addMilestone() {
    final title = state.newMilestone.trim();
    if (title.isEmpty) return;
    emit(state.copyWith(
      milestones: List.unmodifiable([...state.milestones, Milestone(title: title)]),
      newMilestone: '',
      milestoneRevision: state.milestoneRevision + 1,
    ));
  }

  void noteChanged(String text) => emit(state.copyWith(note: text));
}
