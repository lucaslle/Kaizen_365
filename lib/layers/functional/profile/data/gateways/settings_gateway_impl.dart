import '../../../../technical/preferences/app_preferences.dart';
import '../../domain/entities/user_settings.dart';
import '../../domain/gateways/settings_gateway.dart';

class SettingsGatewayImpl implements SettingsGateway {
  SettingsGatewayImpl(this._preferences);

  final AppPreferences _preferences;

  @override
  UserSettings load() {
    final rhythm = _preferences.getString(PreferenceKey.checkinRhythm);
    return UserSettings(
      name: _preferences.getString(PreferenceKey.userName) ?? '',
      rhythm: rhythm == null ? CheckinRhythm.weekly : CheckinRhythm.values.byName(rhythm),
      themeName: _preferences.getString(PreferenceKey.themeName) ?? '',
      languageCode: _preferences.getString(PreferenceKey.languageCode) ?? '',
      reminderMinutes: _preferences.getInt(PreferenceKey.reminderMinutes) ?? UserSettings.defaultReminderMinutes,
      areRemindersEnabled: _preferences.getBool(PreferenceKey.areRemindersEnabled) ?? true,
      hasCompletedOnboarding: _preferences.getBool(PreferenceKey.hasCompletedOnboarding) ?? false,
    );
  }

  @override
  Future<void> save(UserSettings settings) async {
    await _preferences.setString(PreferenceKey.userName, settings.name);
    await _preferences.setString(PreferenceKey.checkinRhythm, settings.rhythm.name);
    await _preferences.setString(PreferenceKey.themeName, settings.themeName);
    await _preferences.setString(PreferenceKey.languageCode, settings.languageCode);
    await _preferences.setInt(PreferenceKey.reminderMinutes, settings.reminderMinutes);
    await _preferences.setBool(PreferenceKey.areRemindersEnabled, settings.areRemindersEnabled);
    await _preferences.setBool(PreferenceKey.hasCompletedOnboarding, settings.hasCompletedOnboarding);
  }
}
