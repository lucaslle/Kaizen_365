import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localization/flutter_localization.dart';

import '../../../../technical/localization/app_locale.dart';
import '../../../../technical/theme/app_palette.dart';
import '../../../../technical/theme/app_text.dart';
import '../../../../technical/theme/widgets/choice_tile.dart';
import '../cubit/settings_cubit.dart';

class LanguageSelector extends StatelessWidget {
  const LanguageSelector({super.key, required this.languageCode});

  final String languageCode;

  static const _options = [
    ('', AppLocale.languageAuto),
    ('fr', AppLocale.languageFrench),
    ('en', AppLocale.languageEnglish),
  ];

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    spacing: 8,
    children: [
      Text(AppLocale.languageLabel.getString(context).toUpperCase(), style: context.text.overline),
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final (code, label) in _options)
            ChoiceTile(
              isSelected: languageCode == code,
              isRadio: true,
              onTap: () => context.read<SettingsCubit>().languageSelected(code),
              selectedBorder: context.palette.accent,
              idleBorder: context.palette.inputBorder,
              radius: 22,
              height: 44,
              child: Center(
                widthFactor: 1,
                child: Text(label.getString(context), style: context.text.sans(14, weight: 500)),
              ),
            ),
        ],
      ),
    ],
  );
}
