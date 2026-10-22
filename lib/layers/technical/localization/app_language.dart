import 'dart:ui';

import 'package:flutter_localization/flutter_localization.dart';
import 'package:intl/intl.dart';

import 'app_locale.dart';

abstract final class AppLanguage {
  static const supported = ['fr', 'en'];
  static const fallback = 'fr';

  /// [preferred] wins when supported; otherwise the phone language, otherwise French.
  static String resolve(String preferred) {
    if (supported.contains(preferred)) return preferred;
    final system = PlatformDispatcher.instance.locale.languageCode;
    return supported.contains(system) ? system : fallback;
  }

  static void apply(String languageCode) {
    FlutterLocalization.instance.translate(languageCode, save: false);
    Intl.defaultLocale = languageCode == 'en' ? 'en_US' : 'fr_FR';
  }

  static String current() => FlutterLocalization.instance.currentLocale?.languageCode ?? fallback;

  /// For text needed outside the widget tree, such as notifications.
  static String text(String key) => (current() == 'en' ? AppLocale.en : AppLocale.fr)[key] as String;
}
