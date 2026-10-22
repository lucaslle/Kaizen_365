import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app/dependency_injection.dart';
import 'app/kaizen_app.dart';
import 'layers/functional/profile/domain/use_cases/get_settings_use_case.dart';
import 'layers/technical/localization/app_language.dart';
import 'layers/technical/localization/app_locale.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting();
  final localization = FlutterLocalization.instance;
  await localization.ensureInitialized();
  localization.init(
    mapLocales: [const MapLocale('fr', AppLocale.fr), const MapLocale('en', AppLocale.en)],
    initLanguageCode: AppLanguage.fallback,
  );
  await initializeDependencies();
  AppLanguage.apply(AppLanguage.resolve(GetIt.instance<GetSettingsUseCase>()().languageCode));
  runApp(const KaizenApp());
}
