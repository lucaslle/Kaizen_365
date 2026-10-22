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
      hasCompletedOnboarding: _preferences.getBool(PreferenceKey.hasCompletedOnboarding) ?? false,
    );
  }

  @override
  Future<void> save(UserSettings settings) async {
    await _preferences.setString(PreferenceKey.userName, settings.name);
    await _preferences.setString(PreferenceKey.checkinRhythm, settings.rhythm.name);
    await _preferences.setBool(PreferenceKey.hasCompletedOnboarding, settings.hasCompletedOnboarding);
  }
}
