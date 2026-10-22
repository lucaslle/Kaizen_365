import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localization/flutter_localization.dart';

import '../../../../technical/localization/app_locale.dart';
import '../../../../technical/theme/app_text.dart';
import '../../../../technical/theme/widgets/app_card.dart';
import '../cubit/objective_wizard_cubit.dart';
import '../cubit/objective_wizard_state.dart';
import 'key_result_draft_form.dart';
import '../../../../../layers/technical/theme/app_palette.dart';
import 'wizard_key_result_tile.dart';

class WizardKeyResultsStep extends StatelessWidget {
  const WizardKeyResultsStep({super.key, required this.state});

  final ObjectiveWizardState state;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ObjectiveWizardCubit>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 22,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 8,
          children: [
            Text(AppLocale.wizardHowTitle.getString(context), style: context.text.stepTitle),
            Text(AppLocale.wizardHowBody.getString(context), style: context.text.bodyMuted),
          ],
        ),
        if (state.keyResults.isNotEmpty)
          Column(
            spacing: 8,
            children: [
              for (final (i, k) in state.keyResults.indexed)
                AppCard(
                  radius: 16,
                  padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
                  child: WizardKeyResultTile(keyResult: k, onDelete: () => cubit.removeKeyResult(i)),
                ),
            ],
          ),
        AppCard(
          key: ValueKey(state.draftRevision),
          radius: 20,
          padding: const EdgeInsets.all(16),
          borderColor: context.palette.inputBorder,
          isDashed: true,
          child: KeyResultDraftForm(state: state),
        ),
      ],
    );
  }
}
