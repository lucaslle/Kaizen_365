import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../../technical/localization/app_locale.dart';
import '../../../../technical/theme/app_palette.dart';
import '../../../../technical/theme/app_palettes.dart';
import '../../../../technical/theme/app_text.dart';
import '../cubit/settings_cubit.dart';
import '../widgets/settings_fields.dart';
import '../widgets/theme_picker.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  static Future<void> open(BuildContext context) =>
      Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const ProfileView()));

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      centerTitle: true,
      leading: IconButton(
        tooltip: AppLocale.back.getString(context),
        icon: const Icon(Symbols.arrow_back_rounded),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Text(AppLocale.profileTitle.getString(context).toUpperCase(), style: context.text.overline),
    ),
    body: BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, state) {
        final settings = state.settings;
        final name = settings.name.trim();
        return ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
          children: [
            Row(
              spacing: 16,
              children: [
                ExcludeSemantics(
                  child: CircleAvatar(
                    radius: 32,
                    backgroundColor: context.palette.inverse,
                    child: Text(
                      name.isEmpty ? '?' : name.characters.first.toUpperCase(),
                      style: context.text.sans(26, weight: 600, color: context.palette.onInverse),
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    name.isEmpty ? AppLocale.profileTitle.getString(context) : name,
                    style: context.text.screenTitle,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),
            NameField(name: settings.name),
            const SizedBox(height: 28),
            RhythmSelector(rhythm: settings.rhythm),
            const SizedBox(height: 8),
            Text(AppLocale.profileReminderHelp.getString(context), style: context.text.caption),
            const SizedBox(height: 28),
            ThemePicker(
              selected: AppPalettes.parse(settings.themeName),
              onSelected: (theme) => context.read<SettingsCubit>().themeSelected(theme.name),
            ),
          ],
        );
      },
    ),
  );
}
