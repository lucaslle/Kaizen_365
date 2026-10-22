import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localization/flutter_localization.dart';

import '../../../../technical/localization/app_locale.dart';
import '../../../../technical/theme/app_palette.dart';
import '../../../../technical/theme/app_text.dart';
import '../../../../technical/theme/widgets/app_text_field.dart';
import '../../../../technical/theme/widgets/choice_tile.dart';
import '../../domain/entities/user_settings.dart';
import '../cubit/settings_cubit.dart';
import '../rhythm_texts.dart';

class NameField extends StatelessWidget {
  const NameField({super.key, required this.name});

  final String name;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    spacing: 8,
    children: [
      Text(AppLocale.firstNameLabel.getString(context).toUpperCase(), style: context.text.overline),
      AppTextField(
        label: AppLocale.firstNameLabel.getString(context),
        hint: AppLocale.firstNameHint.getString(context),
        initialValue: name,
        onChanged: context.read<SettingsCubit>().nameChanged,
        autofillHints: const [AutofillHints.givenName],
        verticalPadding: 16,
        style: context.text.sans(18),
      ),
    ],
  );
}

class RhythmSelector extends StatelessWidget {
  const RhythmSelector({super.key, required this.rhythm});

  final CheckinRhythm rhythm;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 8,
      children: [
        Text(AppLocale.rhythmLabel.getString(context).toUpperCase(), style: context.text.overline),
        for (final option in CheckinRhythm.values)
          ChoiceTile(
            isSelected: rhythm == option,
            isRadio: true,
            onTap: () => context.read<SettingsCubit>().rhythmSelected(option),
            selectedBorder: palette.accent,
            idleBorder: palette.inputBorder,
            height: 56,
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Row(
              children: [
                Expanded(
                  child: Text(rhythmLabelKey(option).getString(context), style: context.text.sans(16, weight: 500)),
                ),
                Container(
                  width: 20,
                  height: 20,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: rhythm == option ? palette.accent : palette.inputBorder, width: 2),
                  ),
                  child: rhythm == option ? CircleAvatar(radius: 5, backgroundColor: palette.accent) : null,
                ),
              ],
            ),
          ),
      ],
    );
  }
}
