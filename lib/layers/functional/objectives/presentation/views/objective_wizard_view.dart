import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:get_it/get_it.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../../technical/localization/app_locale.dart';
import '../../../../technical/theme/app_colors.dart';
import '../../../../technical/theme/app_text.dart';
import '../../../../technical/theme/widgets/app_button.dart';
import '../../../../technical/theme/widgets/motion.dart';
import '../cubit/objective_wizard_cubit.dart';
import '../cubit/objective_wizard_state.dart';
import '../cubit/objectives_cubit.dart';
import '../widgets/wizard_steps.dart';
import '../widgets/wizard_key_results_step.dart';
import 'objective_detail_view.dart';

class ObjectiveWizardView extends StatelessWidget {
  const ObjectiveWizardView({super.key, required this.reminderKey, required this.year});

  final String reminderKey;
  final int year;

  static Future<void> open(BuildContext context, {required String reminderKey}) => Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => BlocProvider(
            create: (_) => ObjectiveWizardCubit(GetIt.I()),
            child: ObjectiveWizardView(reminderKey: reminderKey, year: DateTime.now().year),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) => BlocConsumer<ObjectiveWizardCubit, ObjectiveWizardState>(
        listenWhen: (previous, current) =>
            previous.createdObjectiveId != current.createdObjectiveId || (current.hasFailed && !previous.hasFailed),
        listener: (context, state) {
          if (state.hasFailed) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocale.errorSaving.getString(context))));
            return;
          }
          context.read<ObjectivesCubit>().notifyCreated();
          Navigator.of(context).pushReplacement(
            MaterialPageRoute<void>(builder: (_) => ObjectiveDetailView(objectiveId: state.createdObjectiveId!)),
          );
        },
        builder: (context, state) {
          final cubit = context.read<ObjectiveWizardCubit>();
          final isFirst = state.step == WizardStep.what;
          return PopScope(
            canPop: isFirst,
            onPopInvokedWithResult: (didPop, _) {
              if (!didPop) cubit.back();
            },
            child: Scaffold(
              appBar: AppBar(
                backgroundColor: AppColors.background,
                surfaceTintColor: Colors.transparent,
                centerTitle: true,
                leading: IconButton(
                  tooltip: AppLocale.close.getString(context),
                  icon: const Icon(Symbols.close_rounded, color: AppColors.ink),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                title: Text(AppLocale.wizardTitle.getString(context), style: AppText.sans(16, weight: 600)),
                actions: [
                  SizedBox(
                    width: 56,
                    child: Center(
                      child: Text(context.formatString(AppLocale.wizardStep, [state.step.index + 1]),
                          style: AppText.mono(13, color: AppColors.muted)),
                    ),
                  ),
                ],
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(12),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                    child: Row(
                      spacing: 6,
                      children: [
                        for (final step in WizardStep.values)
                          Expanded(
                            child: AnimatedContainer(
                              duration: Motion.duration(context, const Duration(milliseconds: 300)),
                              height: 4,
                              decoration: BoxDecoration(
                                color: step.index <= state.step.index ? AppColors.accent : AppColors.softBorder,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              body: ListView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                children: [
                  switch (state.step) {
                    WizardStep.what => WizardWhatStep(state: state, year: year),
                    WizardStep.why => WizardWhyStep(state: state),
                    WizardStep.how => WizardKeyResultsStep(state: state),
                    WizardStep.recap => WizardRecapStep(state: state, reminderKey: reminderKey),
                  },
                ],
              ),
              bottomNavigationBar: _WizardActions(state: state),
            ),
          );
        },
      );
}

class _WizardActions extends StatelessWidget {
  const _WizardActions({required this.state});

  final ObjectiveWizardState state;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ObjectiveWizardCubit>();
    final nextKey = switch (state.step) {
      WizardStep.recap => AppLocale.createObjective,
      WizardStep.why when state.why.trim().isEmpty => AppLocale.skip,
      _ => AppLocale.next,
    };
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
        decoration: const BoxDecoration(
          color: AppColors.background,
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: Row(
          spacing: 10,
          children: [
            AppButton(
              label: (state.step == WizardStep.what ? AppLocale.cancel : AppLocale.back).getString(context),
              onPressed: state.step == WizardStep.what ? () => Navigator.of(context).pop() : cubit.back,
              variant: AppButtonVariant.outline,
            ),
            Expanded(
              child: AppButton(label: nextKey.getString(context), onPressed: state.canGoNext ? cubit.next : null),
            ),
          ],
        ),
      ),
    );
  }
}
