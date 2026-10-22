import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/user_settings.dart';
import '../../domain/use_cases/complete_onboarding_use_case.dart';
import '../../domain/use_cases/get_settings_use_case.dart';
import '../../domain/use_cases/schedule_checkin_reminders_use_case.dart';

class OnboardingState {
  const OnboardingState({required this.settings, this.step = 0});

  static const lastStep = 2;

  final UserSettings settings;
  final int step;

  OnboardingState copyWith({UserSettings? settings, int? step}) =>
      OnboardingState(settings: settings ?? this.settings, step: step ?? this.step);
}

class OnboardingCubit extends Cubit<OnboardingState> {
  OnboardingCubit(GetSettingsUseCase getSettings, this._completeOnboarding, this._scheduleReminders)
      : super(OnboardingState(settings: getSettings()));

  final CompleteOnboardingUseCase _completeOnboarding;
  final ScheduleCheckinRemindersUseCase _scheduleReminders;

  /// One-shot biweekly reminders run out, so the series is rebuilt on every launch.
  Future<void> refreshReminders() async {
    if (!state.settings.hasCompletedOnboarding) return;
    try {
      await _scheduleReminders(state.settings.rhythm);
    } catch (error, stackTrace) {
      debugPrint('Scheduling reminders failed: $error\n$stackTrace');
    }
  }

  void nameChanged(String name) => emit(state.copyWith(settings: state.settings.copyWith(name: name)));

  void rhythmSelected(CheckinRhythm rhythm) => emit(state.copyWith(settings: state.settings.copyWith(rhythm: rhythm)));

  Future<void> next() async {
    if (state.step < OnboardingState.lastStep) {
      emit(state.copyWith(step: state.step + 1));
      return;
    }
    await skip();
  }

  Future<void> skip() async {
    final completed = state.settings.copyWith(hasCompletedOnboarding: true);
    emit(state.copyWith(settings: completed));
    try {
      await _completeOnboarding(name: completed.name, rhythm: completed.rhythm);
    } catch (error, stackTrace) {
      debugPrint('Saving settings failed: $error\n$stackTrace');
    }
  }
}
