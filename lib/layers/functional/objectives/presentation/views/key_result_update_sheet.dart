import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localization/flutter_localization.dart';

import '../../../../technical/localization/app_locale.dart';
import '../../../../technical/theme/app_text.dart';
import '../../../../technical/theme/widgets/app_button.dart';
import '../../../../technical/theme/widgets/app_sheet.dart';
import '../../../../technical/theme/widgets/app_text_field.dart';
import '../../../../technical/theme/widgets/progress_track.dart';
import '../../domain/entities/key_result.dart';
import '../../domain/entities/objective.dart';
import '../../domain/entities/progress.dart';
import '../cubit/key_result_update_cubit.dart';
import '../cubit/objectives_cubit.dart';
import '../styles/objective_texts.dart';
import '../../../../../layers/technical/theme/app_palette.dart';
import '../widgets/key_result_editors.dart';

class KeyResultUpdateSheet extends StatelessWidget {
  const KeyResultUpdateSheet({super.key, required this.objective});

  final Objective objective;

  static Future<void> show(BuildContext context, {required Objective objective, required KeyResult keyResult}) {
    final objectivesCubit = context.read<ObjectivesCubit>();
    return showAppSheet(
      context,
      label: context.formatString(AppLocale.updateSheetLabel, [keyResult.title]),
      builder: (_) => MultiBlocProvider(
        providers: [
          BlocProvider.value(value: objectivesCubit),
          BlocProvider(create: (_) => KeyResultUpdateCubit(keyResult)),
        ],
        child: KeyResultUpdateSheet(objective: objective),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<KeyResultUpdateCubit>();
    final keyResult = cubit.keyResult;
    return BlocBuilder<KeyResultUpdateCubit, KeyResultUpdateState>(
      builder: (context, state) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 18,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 4,
            children: [
              Text(context.typeLabel(keyResult.type).toUpperCase(), style: context.text.overline),
              Text(keyResult.title, style: context.text.sheetTitle),
            ],
          ),
          switch (keyResult.type) {
            KeyResultType.numeric => NumericEditor(state: state),
            KeyResultType.percent => PercentEditor(state: state),
            KeyResultType.milestones => MilestonesEditor(state: state),
          },
          ProgressTrack(value: keyResultProgress(cubit.preview), color: context.palette.accent, height: 8),
          AppTextField(
            label: AppLocale.noteLabel.getString(context),
            hint: AppLocale.noteHint.getString(context),
            onChanged: cubit.noteChanged,
            fill: context.palette.field,
            radius: 14,
            style: context.text.sans(15),
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
                  label: AppLocale.save.getString(context),
                  height: 52,
                  onPressed: () {
                    context.read<ObjectivesCubit>().updateKeyResult(
                      objective,
                      keyResult,
                      value: state.value,
                      milestones: state.milestones,
                      note: state.note,
                    );
                    Navigator.of(context).pop();
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
