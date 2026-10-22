import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../../technical/localization/app_locale.dart';
import '../../../../technical/localization/formatters.dart';
import '../../../../technical/theme/app_text.dart';
import '../../../../technical/theme/widgets/app_text_field.dart';
import '../cubit/key_result_update_cubit.dart';
import '../../../../technical/theme/app_palette.dart';
import 'milestone_row.dart';

String _plain(double v) => v == v.roundToDouble() ? v.round().toString() : v.toString();

class NumericEditor extends StatelessWidget {
  const NumericEditor({super.key, required this.state});

  final KeyResultUpdateState state;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<KeyResultUpdateCubit>();
    final k = cubit.keyResult;
    return Row(
      spacing: 12,
      children: [
        _RoundButton(icon: Symbols.remove_rounded, label: AppLocale.decrease, onTap: cubit.decrement, isFilled: false),
        Expanded(
          child: Column(
            spacing: 2,
            children: [
              AppTextField(
                key: ValueKey(state.valueRevision),
                label: AppLocale.currentValue.getString(context),
                initialValue: _plain(state.value),
                onChanged: cubit.valueChanged,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))],
                textAlign: TextAlign.center,
                hasBorder: false,
                fill: Colors.transparent,
                verticalPadding: 0,
                style: context.text.mono(44, weight: 600, height: 1.1, tracking: -0.04),
              ),
              Text(
                context.formatString(AppLocale.targetText, [k.unit, Formatters.number(k.target)]).trim(),
                style: context.text.small,
              ),
            ],
          ),
        ),
        _RoundButton(icon: Symbols.add_rounded, label: AppLocale.increase, onTap: cubit.increment, isFilled: true),
      ],
    );
  }
}

class _RoundButton extends StatelessWidget {
  const _RoundButton({required this.icon, required this.label, required this.onTap, required this.isFilled});

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isFilled;

  @override
  Widget build(BuildContext context) => IconButton(
    tooltip: label.getString(context),
    onPressed: onTap,
    iconSize: 26,
    style: IconButton.styleFrom(
      fixedSize: const Size.square(56),
      backgroundColor: isFilled ? context.palette.inverse : Colors.transparent,
      foregroundColor: isFilled ? context.palette.onInverse : context.palette.ink,
      side: isFilled ? null : BorderSide(color: context.palette.inputBorder, width: 1.5),
    ),
    icon: Icon(icon),
  );
}

class PercentEditor extends StatelessWidget {
  const PercentEditor({super.key, required this.state});

  final KeyResultUpdateState state;

  @override
  Widget build(BuildContext context) => Column(
    spacing: 12,
    children: [
      Text('${state.value.round()}%', style: context.text.mono(52, weight: 600, height: 1, tracking: -0.04)),
      Slider(
        value: state.value.clamp(0, 100),
        max: 100,
        divisions: 20,
        semanticFormatterCallback: (v) => '${v.round()}%',
        label: AppLocale.estimatedProgress.getString(context),
        onChanged: context.read<KeyResultUpdateCubit>().percentChanged,
      ),
    ],
  );
}

class MilestonesEditor extends StatelessWidget {
  const MilestonesEditor({super.key, required this.state});

  final KeyResultUpdateState state;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<KeyResultUpdateCubit>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final (i, m) in state.milestones.indexed)
          MilestoneRow(milestone: m, onToggle: () => cubit.toggleMilestone(i), size: 26, fontSize: 16),
        const SizedBox(height: 6),
        Row(
          spacing: 8,
          children: [
            Expanded(
              child: AppTextField(
                key: ValueKey(state.milestoneRevision),
                label: AppLocale.newMilestone.getString(context),
                hint: AppLocale.newMilestone.getString(context),
                onChanged: cubit.newMilestoneChanged,
                onSubmitted: (_) => cubit.addMilestone(),
                fill: context.palette.field,
                radius: 14,
                style: context.text.sans(15),
              ),
            ),
            IconButton(
              tooltip: AppLocale.addMilestone.getString(context),
              onPressed: cubit.addMilestone,
              style: IconButton.styleFrom(
                fixedSize: const Size.square(48),
                backgroundColor: context.palette.sunken,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              icon: Icon(Symbols.add_rounded, color: context.palette.ink),
            ),
          ],
        ),
      ],
    );
  }
}
