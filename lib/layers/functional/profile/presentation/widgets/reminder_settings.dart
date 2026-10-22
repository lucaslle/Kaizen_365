import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../../technical/localization/app_locale.dart';
import '../../../../technical/localization/formatters.dart';
import '../../../../technical/theme/app_palette.dart';
import '../../../../technical/theme/app_text.dart';
import '../../../../technical/theme/widgets/app_card.dart';
import '../../domain/entities/reminder_schedule.dart';
import '../../domain/entities/user_settings.dart';
import '../cubit/settings_cubit.dart';
import 'settings_fields.dart';

class ReminderSettings extends StatelessWidget {
  const ReminderSettings({super.key, required this.settings, required this.now});

  final UserSettings settings;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<SettingsCubit>();
    final palette = context.palette;
    final next = ReminderSchedule.next(now, settings);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 12,
      children: [
        Text(AppLocale.remindersLabel.getString(context).toUpperCase(), style: context.text.overline),
        AppCard(
          radius: 16,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Column(
            children: [
              MergeSemantics(
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        AppLocale.remindersEnabled.getString(context),
                        style: context.text.sans(16, weight: 500),
                      ),
                    ),
                    Switch(
                      value: settings.areRemindersEnabled,
                      onChanged: cubit.remindersToggled,
                      activeTrackColor: palette.accent,
                      inactiveTrackColor: palette.strongBorder,
                      thumbColor: WidgetStatePropertyAll(palette.surface),
                      trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
                    ),
                  ],
                ),
              ),
              if (settings.areRemindersEnabled) ...[
                Divider(height: 1, color: palette.border),
                InkWell(
                  onTap: () => _pickTime(context),
                  child: SizedBox(
                    height: 56,
                    child: Row(
                      spacing: 8,
                      children: [
                        Expanded(
                          child: Text(
                            AppLocale.reminderTimeLabel.getString(context),
                            style: context.text.sans(16, weight: 500),
                          ),
                        ),
                        Text(Formatters.time(settings.reminderMinutes), style: context.text.mono(16, weight: 600)),
                        Icon(Symbols.schedule_rounded, size: 20, color: palette.muted),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        if (settings.areRemindersEnabled) ...[
          RhythmSelector(rhythm: settings.rhythm),
          if (next != null)
            Text(
              context.formatString(AppLocale.nextReminder, [Formatters.weekdayAndTime(next)]),
              style: context.text.caption,
            ),
          Text(AppLocale.profileReminderHelp.getString(context), style: context.text.caption),
        ],
      ],
    );
  }

  Future<void> _pickTime(BuildContext context) async {
    final cubit = context.read<SettingsCubit>();
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: settings.reminderMinutes ~/ 60, minute: settings.reminderMinutes % 60),
    );
    if (picked != null) cubit.reminderTimeSelected(picked.hour * 60 + picked.minute);
  }
}
