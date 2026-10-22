import 'package:flutter/foundation.dart';
import 'package:home_widget/home_widget.dart';

/// Pushes text to the Android home screen widget. Silently does nothing where widgets are unsupported.
abstract final class HomeScreenWidget {
  static const _androidName = 'KaizenWidgetProvider';

  static Future<void> update(Map<String, String> values) async {
    if (defaultTargetPlatform != TargetPlatform.android) return;
    try {
      for (final MapEntry(:key, :value) in values.entries) {
        await HomeWidget.saveWidgetData<String>(key, value);
      }
      await HomeWidget.updateWidget(androidName: _androidName);
    } catch (error) {
      debugPrint('Home screen widget update failed: $error');
    }
  }
}
