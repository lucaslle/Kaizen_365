import 'package:flutter/foundation.dart';
import 'package:home_widget/home_widget.dart';

/// Pushes values to the Android home screen widgets. Silently does nothing where widgets are unsupported.
abstract final class HomeScreenWidget {
  static const _providers = [
    'KaizenWidgetProvider',
    'ScoreWidgetProvider',
    'CheckinWidgetProvider',
    'ObjectivesWidgetProvider',
  ];
  static const _checkinHost = 'checkin';

  static bool get _isSupported => !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  /// Values are strings or integers (progress bars).
  static Future<void> update(Map<String, Object> values) async {
    if (!_isSupported) return;
    try {
      for (final MapEntry(:key, :value) in values.entries) {
        await HomeWidget.saveWidgetData<Object>(key, value);
      }
      for (final provider in _providers) {
        await HomeWidget.updateWidget(androidName: provider);
      }
    } catch (error) {
      debugPrint('Home screen widget update failed: $error');
    }
  }

  /// Emits when the check-in widget opened the app, including the launch it caused.
  static Stream<void> checkinRequests() async* {
    if (!_isSupported) return;
    try {
      if ((await HomeWidget.initiallyLaunchedFromHomeWidget())?.host == _checkinHost) yield null;
    } catch (error) {
      debugPrint('Home screen widget launch check failed: $error');
      return;
    }
    yield* HomeWidget.widgetClicked
        .handleError((Object error) => debugPrint('Home screen widget click failed: $error'))
        .where((uri) => uri?.host == _checkinHost);
  }
}
