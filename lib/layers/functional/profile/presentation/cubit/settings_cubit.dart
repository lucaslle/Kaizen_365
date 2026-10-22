import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/user_settings.dart';
import '../../domain/use_cases/complete_onboarding_use_case.dart';
import '../../domain/use_cases/get_settings_use_case.dart';
import '../../domain/use_cases/schedule_checkin_reminders_use_case.dart';
import '../../domain/use_cases/update_settings_use_case.dart';

class SettingsState {
  const SettingsState({required this.settings, this.onboardingStep = 0});

  static const lastOnboardingStep = 2;

  final UserSettings settings;
  final int onboardingStep;

  SettingsState copyWith({UserSettings? settings, int? onboardingStep}) =>
      SettingsState(settings: settings ?? this.settings, onboardingStep: onboardingStep ?? this.onboardingStep);
}

class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit(GetSettingsUseCase getSettings, this._completeOnboarding, this._updateSettings, this._scheduleReminders)
    : super(SettingsState(settings: getSettings()));

  final CompleteOnboardingUseCase _completeOnboarding;
  final UpdateSettingsUseCase _updateSettings;
  final ScheduleCheckinRemindersUseCase _scheduleReminders;

  /// One-shot biweekly reminders run out, so the series is rebuilt on every launch.
  Future<void> refreshReminders() => _guard(() async {
    if (state.settings.hasCompletedOnboarding) await _scheduleReminders(state.settings.rhythm);
  });

  void nameChanged(String name) => _change(state.settings.copyWith(name: name.trim()));

  void rhythmSelected(CheckinRhythm rhythm) => _change(state.settings.copyWith(rhythm: rhythm));

  void themeSelected(String themeName) => _change(state.settings.copyWith(themeName: themeName));

  Future<void> nextOnboardingStep() async {
    if (state.onboardingStep < SettingsState.lastOnboardingStep) {
      emit(state.copyWith(onboardingStep: state.onboardingStep + 1));
      return;
    }
    await completeOnboarding();
  }

  Future<void> completeOnboarding() async {
    final draft = state.settings;
    emit(state.copyWith(settings: draft.copyWith(hasCompletedOnboarding: true)));
    await _guard(() => _completeOnboarding(draft));
  }

  void _change(UserSettings next) {
    final previous = state.settings;
    emit(state.copyWith(settings: next));
    if (previous.hasCompletedOnboarding) _guard(() => _updateSettings(previous, next));
  }

  Future<void> _guard(Future<void> Function() action) async {
    try {
      await action();
    } catch (error, stackTrace) {
      debugPrint('Saving settings failed: $error\n$stackTrace');
    }
  }
}
