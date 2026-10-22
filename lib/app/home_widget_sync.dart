import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localization/flutter_localization.dart';

import '../layers/functional/objectives/domain/entities/progress.dart';
import '../layers/functional/objectives/presentation/cubit/objectives_cubit.dart';
import '../layers/functional/objectives/presentation/cubit/objectives_state.dart';
import '../layers/functional/profile/domain/entities/reminder_schedule.dart';
import '../layers/functional/profile/presentation/cubit/settings_cubit.dart';
import '../layers/technical/home_screen_widget/home_screen_widget.dart';
import '../layers/technical/localization/app_locale.dart';
import '../layers/technical/localization/formatters.dart';

/// Keeps the home screen widget in step with the objectives and the reminder settings.
class HomeWidgetSync extends StatelessWidget {
  const HomeWidgetSync({super.key, required this.child});

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
    final objectives = context.read<ObjectivesCubit>().state;
    if (objectives.status != ObjectivesStatus.ready) return;
    final settings = context.read<SettingsCubit>().state.settings;
    final next = ReminderSchedule.next(objectives.now, settings);
    HomeScreenWidget.update({
      'year': context.formatString(AppLocale.yearLabel, [objectives.activeYear]),
      'score': Formatters.percent(yearScore(objectives.objectives)),
      'scoreLabel': AppLocale.yourProgress.getString(context),
      'elapsed': Formatters.percent(expectedProgress(objectives.now, year: objectives.activeYear)),
      'elapsedLabel': AppLocale.timeElapsed.getString(context),
      'next': next == null ? '' : context.formatString(AppLocale.nextReminder, [Formatters.weekdayAndTime(next)]),
    });
  }
}
