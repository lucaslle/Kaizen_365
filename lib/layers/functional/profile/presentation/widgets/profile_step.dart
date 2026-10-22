import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';

import '../../../../technical/localization/app_locale.dart';
import '../../../../technical/theme/app_text.dart';
import '../../domain/entities/user_settings.dart';
import 'settings_fields.dart';

class ProfileStep extends StatelessWidget {
  const ProfileStep({super.key, required this.settings});

  final UserSettings settings;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    spacing: 28,
    children: [
      Text(AppLocale.meetTitle.getString(context), style: context.text.onboardingTitle),
      NameField(name: settings.name),
      RhythmSelector(rhythm: settings.rhythm),
    ],
  );
}
