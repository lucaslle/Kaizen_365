import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localization/flutter_localization.dart';

import '../layers/functional/objectives/domain/entities/objective_sort.dart';
import '../layers/functional/objectives/domain/entities/progress.dart';
import '../layers/functional/objectives/presentation/cubit/objectives_cubit.dart';
import '../layers/functional/objectives/presentation/cubit/objectives_state.dart';
import '../layers/functional/objectives/presentation/styles/status_style.dart';
import '../layers/functional/profile/domain/entities/reminder_schedule.dart';
import '../layers/functional/profile/presentation/cubit/settings_cubit.dart';
import '../layers/technical/home_screen_widget/home_screen_widget.dart';
import '../layers/technical/localization/app_locale.dart';
import '../layers/technical/localization/formatters.dart';

/// Keeps the home screen widgets in step with the objectives and the reminder settings.
class HomeWidgetSync extends StatelessWidget {
  const HomeWidgetSync({super.key, required this.child});

  static const _maxObjectives = 5;

  final Widget child;

  @override
  Widget build(BuildContext context) => MultiBlocListener(
    listeners: [
      BlocListener<ObjectivesCubit, ObjectivesState>(listener: (context, _) => _push(context)),
      BlocListener<SettingsCubit, SettingsState>(listener: (context, _) => _push(context)),
    ],
    child: child,
  );

  void _push(BuildContext context) {
    final state = context.read<ObjectivesCubit>().state;
    if (state.status != ObjectivesStatus.ready) return;
    final settings = context.read<SettingsCubit>().state.settings;
    final next = ReminderSchedule.next(state.now, settings);
    final expected = expectedProgress(state.now, year: state.activeYear);
    final score = yearScore(state.objectives);
    final objectives = sortObjectives(state.objectives, state.sort, expected).take(_maxObjectives).toList();
    HomeScreenWidget.update({
      'year': context.formatString(AppLocale.yearLabel, [state.activeYear]),
      'score': Formatters.percent(score),
      'scorePercent': (score * 100).round(),
      'scoreLabel': AppLocale.yourProgress.getString(context),
      'elapsed': Formatters.percent(expected),
      'elapsedLabel': AppLocale.timeElapsed.getString(context),
      'elapsedShort': context.formatString(AppLocale.widgetElapsed, [Formatters.percent(expected)]),
      'next': next == null ? '' : context.formatString(AppLocale.nextReminder, [Formatters.weekdayAndTime(next)]),
      'nextShort': next == null ? '' : Formatters.weekdayAndTime(next),
      'checkinLabel': AppLocale.widgetCheckin.getString(context),
      'emptyObjectives': AppLocale.emptyTitle.getString(context),
      'objectiveCount': objectives.length,
      for (final (i, objective) in objectives.indexed) ...{
        'objective${i}Title': objective.title,
        'objective${i}Percent': Formatters.percent(objectiveProgress(objective)),
        'objective${i}Progress': (objectiveProgress(objective) * 100).round(),
        'objective${i}Status': statusFor(objectiveProgress(objective), expected).name,
        'objective${i}StatusLabel': StatusStyle.of(
          statusFor(objectiveProgress(objective), expected),
        ).labelKey.getString(context),
      },
    });
  }
}
