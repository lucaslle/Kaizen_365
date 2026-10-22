import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

import 'app/dependency_injection.dart';
import 'app/kaizen_app.dart';
import 'layers/technical/localization/app_locale.dart';
import 'layers/technical/localization/formatters.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Intl.defaultLocale = Formatters.locale;
  await initializeDateFormatting(Formatters.locale);
  final localization = FlutterLocalization.instance;
  await localization.ensureInitialized();
  localization.init(mapLocales: [const MapLocale('fr', AppLocale.fr)], initLanguageCode: 'fr');
  await initializeDependencies();
  runApp(const KaizenApp());
}
