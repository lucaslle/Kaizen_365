import 'package:shared_preferences/shared_preferences.dart';

enum PreferenceKey {
  userName,
  checkinRhythm,
  hasCompletedOnboarding,
  themeName,
  isYearClosed,
  carriedObjectiveIds,
  reflectionProud,
  reflectionLearned,
  reflectionNext,
}

class AppPreferences {
  AppPreferences(this._prefs);

  final SharedPreferencesWithCache _prefs;

  static Future<AppPreferences> create() async =>
      AppPreferences(await SharedPreferencesWithCache.create(cacheOptions: const SharedPreferencesWithCacheOptions()));

  String? getString(PreferenceKey key) => _prefs.getString(key.name);
  bool? getBool(PreferenceKey key) => _prefs.getBool(key.name);
  List<String>? getStringList(PreferenceKey key) => _prefs.getStringList(key.name);

  Future<void> setString(PreferenceKey key, String value) => _prefs.setString(key.name, value);
  Future<void> setBool(PreferenceKey key, bool value) => _prefs.setBool(key.name, value);
  Future<void> setStringList(PreferenceKey key, List<String> value) => _prefs.setStringList(key.name, value);
}
