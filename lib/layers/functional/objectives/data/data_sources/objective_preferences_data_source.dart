import 'dart:convert';

import '../../../../technical/preferences/app_preferences.dart';
import 'objective_store.dart';

class ObjectivePreferencesDataSource implements ObjectiveStore {
  ObjectivePreferencesDataSource(this._preferences);

  final AppPreferences _preferences;

  @override
  Future<List<Map<String, dynamic>>> read() async {
    final raw = _preferences.getString(PreferenceKey.objectivesJson);
    return raw == null ? [] : (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
  }

  @override
  Future<void> write(List<Map<String, dynamic>> objectives) =>
      _preferences.setString(PreferenceKey.objectivesJson, jsonEncode(objectives));
}
