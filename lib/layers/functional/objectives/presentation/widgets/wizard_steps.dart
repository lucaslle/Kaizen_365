import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../../technical/localization/app_locale.dart';
import '../../../../technical/theme/app_text.dart';
import '../../../../technical/theme/widgets/app_card.dart';
import '../../../../technical/theme/widgets/app_text_field.dart';
import '../../../../technical/theme/widgets/choice_tile.dart';
import '../../domain/entities/life_domain.dart';
import '../cubit/objective_wizard_cubit.dart';
import '../cubit/objective_wizard_state.dart';
import '../styles/domain_style.dart';
import 'domain_label.dart';
import '../../../../../layers/technical/theme/app_palette.dart';
import 'wizard_key_result_tile.dart';

const _suggestions = [
  AppLocale.suggestionRun,
  AppLocale.suggestionMeditate,
  AppLocale.suggestionTravel,
  AppLocale.suggestionGuitar,
];

class WizardWhatStep extends StatelessWidget {
  const WizardWhatStep({super.key, required this.state, required this.year});

  final ObjectiveWizardState state;
  final int year;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ObjectiveWizardCubit>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 22,
      children: [
        Text(context.formatString(AppLocale.wizardWhatTitle, [year]), style: context.text.stepTitle),
        AppTextField(
          key: ValueKey(state.titleRevision),
          label: AppLocale.objectiveLabel.getString(context),
          hint: AppLocale.objectiveHint.getString(context),
          initialValue: state.title,
          onChanged: cubit.titleChanged,
          lines: 2,
          style: context.text.sans(19, weight: 500, height: 1.3),
        ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final key in _suggestions)
              ActionChip(
                label: Text(key.getString(context), style: context.text.sans(13, weight: 500)),
                onPressed: () => cubit.suggestionPicked(key.getString(context)),
                backgroundColor: context.palette.sunken,
                side: BorderSide.none,
                shape: const StadiumBorder(),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
              ),
          ],
        ),
        Text(AppLocale.domainLabel.getString(context).toUpperCase(), style: context.text.overline),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          childAspectRatio: 3,
          children: [
            for (final domain in LifeDomain.values)
              ChoiceTile(
                isSelected: state.domain == domain,
                onTap: () => cubit.domainSelected(domain),
                selectedBorder: DomainStyle.of(domain).color,
                idleBorder: context.palette.softBorder,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Row(
                  spacing: 10,
                  children: [
                    Icon(DomainStyle.of(domain).icon, size: 22, fill: 1, color: DomainStyle.of(domain).color),
                    Flexible(
                      child: Text(
                        DomainStyle.of(domain).labelKey.getString(context),
                        style: context.text.sans(15, weight: 500),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class WizardWhyStep extends StatelessWidget {
  const WizardWhyStep({super.key, required this.state});

  final ObjectiveWizardState state;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    spacing: 22,
    children: [
      Text(AppLocale.wizardWhyTitle.getString(context), style: context.text.stepTitle),
      AppTextField(
        label: AppLocale.whyLabel.getString(context),
        hint: AppLocale.whyHint.getString(context),
        initialValue: state.why,
        onChanged: context.read<ObjectiveWizardCubit>().whyChanged,
        lines: 5,
        style: context.text.sans(17, height: 1.45),
      ),
      AppCard(
        color: context.palette.sunken,
        hasBorder: false,
        radius: 16,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 12,
          children: [
            Icon(Symbols.lightbulb_rounded, size: 22, color: context.palette.accent),
            Expanded(
              child: Text(
                AppLocale.whyTip.getString(context),
                style: context.text.sans(14, height: 1.45, color: context.palette.ink3),
              ),
            ),
          ],
        ),
      ),
    ],
  );
}

class WizardRecapStep extends StatelessWidget {
  const WizardRecapStep({super.key, required this.state, required this.reminderKey});

  final ObjectiveWizardState state;
  final String reminderKey;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    spacing: 22,
    children: [
      Text(AppLocale.wizardReadyTitle.getString(context), style: context.text.stepTitle),
      AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 12,
          children: [
            DomainLabel(domain: state.domain),
            Text(state.title.trim(), style: context.text.sans(22, weight: 600, height: 1.15, tracking: -0.02)),
            if (state.why.trim().isNotEmpty)
              Text('« ${state.why.trim()} »', style: context.text.bodyMuted.copyWith(fontStyle: FontStyle.italic)),
            Divider(height: 1, color: context.palette.border),
            for (final k in state.keyResults) WizardKeyResultTile(keyResult: k, isCompact: true),
          ],
        ),
      ),
      Text(
        context.formatString(AppLocale.reminderText, [reminderKey.getString(context)]),
        style: context.text.sans(14, height: 1.45, color: context.palette.muted),
      ),
    ],
  );
}
