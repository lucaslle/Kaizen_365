import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localization/flutter_localization.dart';

import '../../../../technical/localization/app_locale.dart';
import '../../../../technical/theme/app_text.dart';
import '../../../../technical/theme/widgets/app_button.dart';
import '../../../../technical/theme/widgets/motion.dart';
import '../cubit/settings_cubit.dart';
import '../widgets/onboarding_steps.dart';
import '../../../../../layers/technical/theme/app_palette.dart';
import '../widgets/profile_step.dart';

class OnboardingView extends StatelessWidget {
  const OnboardingView({super.key});

  @override
  Widget build(BuildContext context) => BlocBuilder<SettingsCubit, SettingsState>(
    builder: (context, state) {
      final cubit = context.read<SettingsCubit>();
      final isLast = state.onboardingStep == SettingsState.lastOnboardingStep;
      return Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 4, 24, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  height: 52,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        spacing: 6,
                        children: [
                          for (var i = 0; i <= SettingsState.lastOnboardingStep; i++)
                            AnimatedContainer(
                              duration: Motion.duration(context, const Duration(milliseconds: 300)),
                              width: i == state.onboardingStep ? 24 : 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: i == state.onboardingStep ? context.palette.accent : context.palette.inputBorder,
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                        ],
                      ),
                      TextButton(
                        onPressed: cubit.completeOnboarding,
                        style: TextButton.styleFrom(minimumSize: const Size(48, 48)),
                        child: Text(
                          AppLocale.skip.getString(context),
                          style: context.text.sans(15, weight: 500, color: context.palette.muted),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      child: switch (state.onboardingStep) {
                        0 => const WelcomeStep(),
                        1 => const HowItWorksStep(),
                        _ => ProfileStep(settings: state.settings),
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                AppButton(
                  label: (isLast ? AppLocale.startYear : AppLocale.continueLabel).getString(context),
                  onPressed: cubit.nextOnboardingStep,
                  height: 56,
                  fontSize: 17,
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
