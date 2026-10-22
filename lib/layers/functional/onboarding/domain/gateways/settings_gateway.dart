import '../entities/user_settings.dart';

abstract interface class SettingsGateway {
  UserSettings load();

  Future<void> save(UserSettings settings);
}
