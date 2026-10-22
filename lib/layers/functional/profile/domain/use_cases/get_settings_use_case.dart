import '../entities/user_settings.dart';
import '../gateways/settings_gateway.dart';

class GetSettingsUseCase {
  GetSettingsUseCase(this._gateway);

  final SettingsGateway _gateway;

  UserSettings call() => _gateway.load();
}
