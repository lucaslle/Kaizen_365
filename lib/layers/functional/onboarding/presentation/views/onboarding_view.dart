import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localization/flutter_localization.dart';

import '../../../../technical/localization/app_locale.dart';
import '../../../../technical/theme/app_colors.dart';
import '../../../../technical/theme/app_text.dart';
import '../../../../technical/theme/widgets/app_button.dart';
import '../../../../technical/theme/widgets/motion.dart';
import '../cubit/onboarding_cubit.dart';
import '../widgets/onboarding_steps.dart';
import '../widgets/profile_step.dart';

class OnboardingView extends StatelessWidget {
  const OnboardingView({super.key});

  @override
  Widget build(BuildContext context) => BlocBuilder<OnboardingCubit, OnboardingState>(
        builder: (context, state) {
          final cubit = context.read<OnboardingCubit>();
          final isLast = state.step == OnboardingState.lastStep;
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
                              for (var i = 0; i <= OnboardingState.lastStep; i++)
                                AnimatedContainer(
                                  duration: Motion.duration(context, const Duration(milliseconds: 300)),
                                  width: i == state.step ? 24 : 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: i == state.step ? AppColors.accent : AppColors.inputBorder,
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                ),
                            ],
                          ),
                          TextButton(
                            onPressed: cubit.skip,
                            style: TextButton.styleFrom(minimumSize: const Size(48, 48)),
                            child: Text(AppLocale.skip.getString(context), style: AppText.sans(15, weight: 500, color: AppColors.muted)),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Center(
                        child: SingleChildScrollView(
                          child: switch (state.step) {
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
                      onPressed: cubit.next,
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
