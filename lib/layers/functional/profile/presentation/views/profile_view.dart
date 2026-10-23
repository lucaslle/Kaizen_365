import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:get_it/get_it.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../../technical/clock/clock.dart';
import '../../../../technical/localization/app_locale.dart';
import '../../../../technical/theme/app_palette.dart';
import '../../../../technical/theme/app_palettes.dart';
import '../../../../technical/theme/app_text.dart';
import '../cubit/settings_cubit.dart';
import '../../../../technical/theme/widgets/toast.dart';
import '../widgets/language_selector.dart';
import '../widgets/reminder_settings.dart';
import '../widgets/settings_fields.dart';
import '../widgets/theme_picker.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key, this.extraSections = const []});

  /// Sections owned by other layers, such as data backup, shown at the bottom.
  final List<Widget> extraSections;

  static Future<void> open(BuildContext context, {List<Widget> extraSections = const []}) =>
      Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => ProfileView(extraSections: extraSections)));

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
    body: BlocConsumer<SettingsCubit, SettingsState>(
      listenWhen: (previous, current) => current.wasPermissionRefused,
      listener: (context, state) => showToast(context, AppLocale.permissionRefused.getString(context), isError: true),
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
            ReminderSettings(settings: settings, now: GetIt.I<Clock>()()),
            const SizedBox(height: 28),
            ThemePicker(
              selected: AppPalettes.parse(settings.themeName),
              onSelected: (theme) => context.read<SettingsCubit>().themeSelected(theme.name),
            ),
            const SizedBox(height: 28),
            LanguageSelector(languageCode: settings.languageCode),
            for (final section in extraSections) ...[const SizedBox(height: 28), section],
          ],
        );
      },
    ),
  );
}
