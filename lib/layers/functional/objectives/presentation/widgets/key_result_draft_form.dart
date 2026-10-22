import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../../technical/localization/app_locale.dart';
import '../../../../technical/theme/app_text.dart';
import '../../../../technical/theme/widgets/app_button.dart';
import '../../../../technical/theme/widgets/app_text_field.dart';
import '../../../../technical/theme/widgets/segmented_pill.dart';
import '../../domain/entities/key_result.dart';
import '../cubit/objective_wizard_cubit.dart';
import '../../../../../layers/technical/theme/app_palette.dart';
import '../cubit/objective_wizard_state.dart';

class KeyResultDraftForm extends StatelessWidget {
  const KeyResultDraftForm({super.key, required this.state});

  final ObjectiveWizardState state;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ObjectiveWizardCubit>();
    final draft = state.draft;
    final decimal = [FilteringTextInputFormatter.allow(RegExp(r'[-0-9.,]'))];
    Widget numberField(
      String caption,
      String label,
      String value,
      String? hint,
      ValueChanged<String> onChanged, {
      bool isNumber = true,
    }) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 4,
      children: [
        Text(caption.getString(context), style: context.text.sans(12, color: context.palette.muted)),
        AppTextField(
          label: label.getString(context),
          hint: hint?.getString(context),
          initialValue: value,
          onChanged: onChanged,
          fill: context.palette.field,
          radius: 12,
          keyboardType: isNumber ? const TextInputType.numberWithOptions(decimal: true, signed: true) : null,
          inputFormatters: isNumber ? decimal : null,
          style: isNumber ? context.text.mono(15) : context.text.sans(15),
        ),
      ],
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 12,
      children: [
        AppTextField(
          label: AppLocale.keyResultNameLabel.getString(context),
          hint: AppLocale.keyResultNameHint.getString(context),
          onChanged: (v) => cubit.draftChanged(draft.copyWith(title: v)),
          fill: context.palette.field,
          radius: 14,
        ),
        SegmentedPill<KeyResultType>(
          segments: [
            (KeyResultType.numeric, AppLocale.segmentNumeric.getString(context)),
            (KeyResultType.percent, AppLocale.segmentPercent.getString(context)),
            (KeyResultType.milestones, AppLocale.segmentMilestones.getString(context)),
          ],
          selected: draft.type,
          onSelected: (type) => cubit.draftChanged(draft.copyWith(type: type)),
        ),
        if (draft.type == KeyResultType.numeric)
          Row(
            spacing: 8,
            children: [
              Expanded(
                child: numberField(
                  AppLocale.startField,
                  AppLocale.startFieldLabel,
                  draft.start,
                  null,
                  (v) => cubit.draftChanged(draft.copyWith(start: v)),
                ),
              ),
              Expanded(
                child: numberField(
                  AppLocale.targetField,
                  AppLocale.targetFieldLabel,
                  draft.target,
                  AppLocale.targetHint,
                  (v) => cubit.draftChanged(draft.copyWith(target: v)),
                ),
              ),
              Expanded(
                child: numberField(
                  AppLocale.unitField,
                  AppLocale.unitField,
                  draft.unit,
                  AppLocale.unitHint,
                  (v) => cubit.draftChanged(draft.copyWith(unit: v)),
                  isNumber: false,
                ),
              ),
            ],
          ),
        if (draft.type == KeyResultType.percent)
          Text(
            AppLocale.percentHelp.getString(context),
            style: context.text.sans(14, height: 1.4, color: context.palette.muted),
          ),
        if (draft.type == KeyResultType.milestones) ...[
          for (final (i, title) in draft.milestones.indexed)
            Row(
              spacing: 10,
              children: [
                SizedBox(width: 18, child: Text('${i + 1}', style: context.text.monoSmall)),
                Expanded(child: Text(title, style: context.text.body)),
                IconButton(
                  tooltip: context.formatString(AppLocale.deleteMilestone, [title]),
                  onPressed: () => cubit.removeDraftMilestone(i),
                  icon: Icon(Symbols.close_rounded, size: 18, color: context.palette.muted),
                ),
              ],
            ),
          Row(
            spacing: 8,
            children: [
              Expanded(
                child: AppTextField(
                  key: ValueKey(state.milestoneRevision),
                  label: AppLocale.newMilestone.getString(context),
                  hint: AppLocale.addMilestoneHint.getString(context),
                  onChanged: (v) => cubit.draftChanged(draft.copyWith(milestoneInput: v)),
                  onSubmitted: (_) => cubit.addDraftMilestone(),
                  fill: context.palette.field,
                  radius: 12,
                  style: context.text.sans(15),
                ),
              ),
              IconButton(
                tooltip: AppLocale.addMilestone.getString(context),
                onPressed: cubit.addDraftMilestone,
                style: IconButton.styleFrom(
                  fixedSize: const Size.square(46),
                  backgroundColor: context.palette.inverse,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: Icon(Symbols.add_rounded, color: context.palette.onInverse),
              ),
            ],
          ),
        ],
        AppButton(
          label: AppLocale.addKeyResult.getString(context),
          onPressed: draft.isValid ? cubit.addKeyResult : null,
          variant: AppButtonVariant.dark,
          height: 46,
          fontSize: 15,
        ),
      ],
    );
  }
}
