import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localization/flutter_localization.dart';

import '../../../../technical/localization/app_locale.dart';
import '../../../../technical/theme/app_colors.dart';
import '../../../../technical/theme/app_text.dart';
import '../../../../technical/theme/widgets/app_text_field.dart';
import '../../../../technical/theme/widgets/choice_tile.dart';
import '../../domain/entities/user_settings.dart';
import '../cubit/onboarding_cubit.dart';
import '../rhythm_texts.dart';

class ProfileStep extends StatelessWidget {
  const ProfileStep({super.key, required this.settings});

  final UserSettings settings;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<OnboardingCubit>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 28,
      children: [
        Text(AppLocale.meetTitle.getString(context), style: AppText.onboardingTitle),
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 8,
          children: [
            Text(AppLocale.firstNameLabel.getString(context).toUpperCase(), style: AppText.overline),
            AppTextField(
              label: AppLocale.firstNameLabel.getString(context),
              hint: AppLocale.firstNameHint.getString(context),
              initialValue: settings.name,
              onChanged: cubit.nameChanged,
              autofillHints: const [AutofillHints.givenName],
              verticalPadding: 16,
              style: AppText.sans(18),
            ),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 8,
          children: [
            Text(AppLocale.rhythmLabel.getString(context).toUpperCase(), style: AppText.overline),
            for (final rhythm in CheckinRhythm.values)
              ChoiceTile(
                isSelected: settings.rhythm == rhythm,
                isRadio: true,
                onTap: () => cubit.rhythmSelected(rhythm),
                selectedBorder: AppColors.accent,
                idleBorder: AppColors.inputBorder,
                height: 56,
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Row(
                  children: [
                    Expanded(child: Text(rhythmLabelKey(rhythm).getString(context), style: AppText.sans(16, weight: 500))),
                    _RadioDot(isSelected: settings.rhythm == rhythm),
                  ],
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _RadioDot extends StatelessWidget {
  const _RadioDot({required this.isSelected});

  final bool isSelected;

  @override
  Widget build(BuildContext context) => Container(
        width: 20,
        height: 20,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: isSelected ? AppColors.accent : AppColors.inputBorder, width: 2),
        ),
        child: isSelected ? const CircleAvatar(radius: 5, backgroundColor: AppColors.accent) : null,
      );
}
