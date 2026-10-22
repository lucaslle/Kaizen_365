import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localization/flutter_localization.dart';

import '../../../../technical/localization/app_locale.dart';
import '../../../../technical/localization/formatters.dart';
import '../../../../technical/theme/app_colors.dart';
import '../../../../technical/theme/app_text.dart';
import '../../../../technical/theme/widgets/app_button.dart';
import '../../../../technical/theme/widgets/app_sheet.dart';
import '../../../../technical/theme/widgets/app_text_field.dart';
import '../../../../technical/theme/widgets/choice_tile.dart';
import '../../domain/entities/mood.dart';
import '../../domain/entities/objective.dart';
import '../cubit/checkin_draft_cubit.dart';
import '../cubit/objectives_cubit.dart';
import '../styles/mood_style.dart';

class CheckinSheet extends StatelessWidget {
  const CheckinSheet({super.key, required this.objective});

  final Objective objective;

  static Future<void> show(BuildContext context, {required Objective objective}) {
    final objectivesCubit = context.read<ObjectivesCubit>();
    return showAppSheet(
      context,
      label: AppLocale.newCheckinLabel.getString(context),
      builder: (_) => MultiBlocProvider(
        providers: [
          BlocProvider.value(value: objectivesCubit),
          BlocProvider(create: (_) => CheckinDraftCubit()),
        ],
        child: CheckinSheet(objective: objective),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => BlocBuilder<CheckinDraftCubit, CheckinDraft>(
        builder: (context, draft) {
          final cubit = context.read<CheckinDraftCubit>();
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 18,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 4,
                children: [
                  Text(context.formatString(AppLocale.checkinOverline, [Formatters.shortDate(DateTime.now())]).toUpperCase(),
                      style: AppText.overline),
                  Text(AppLocale.checkinTitle.getString(context), style: AppText.sheetTitle),
                ],
              ),
              Row(
                spacing: 8,
                children: [
                  for (final mood in Mood.values)
                    Expanded(
                      child: ChoiceTile(
                        isSelected: draft.mood == mood,
                        onTap: () => cubit.moodSelected(mood),
                        selectedFill: AppColors.background,
                        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
                        child: Column(
                          spacing: 6,
                          children: [
                            Icon(MoodStyle.of(mood).icon, size: 30, fill: draft.mood == mood ? 1 : 0, color: MoodStyle.of(mood).color),
                            Text(MoodStyle.of(mood).labelKey.getString(context), style: AppText.label),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
              AppTextField(
                label: AppLocale.checkinLabel.getString(context),
                hint: AppLocale.checkinHint.getString(context),
                onChanged: cubit.textChanged,
                lines: 4,
                fill: AppColors.field,
                style: AppText.sans(16, height: 1.45),
              ),
              Row(
                spacing: 10,
                children: [
                  AppButton(
                    label: AppLocale.cancel.getString(context),
                    onPressed: () => Navigator.of(context).pop(),
                    variant: AppButtonVariant.outline,
                    height: 52,
                    padding: 20,
                  ),
                  Expanded(
                    child: AppButton(
                      label: AppLocale.publishCheckin.getString(context),
                      height: 52,
                      onPressed: draft.canPublish
                          ? () {
                              context.read<ObjectivesCubit>().addCheckin(objective, mood: draft.mood, text: draft.text);
                              Navigator.of(context).pop();
                            }
                          : null,
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      );
}
