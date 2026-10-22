import '../../../../technical/preferences/app_preferences.dart';
import '../../domain/entities/objective_sort.dart';
import '../../domain/gateways/objective_preferences_gateway.dart';

class ObjectivePreferencesGatewayImpl implements ObjectivePreferencesGateway {
  ObjectivePreferencesGatewayImpl(this._preferences);

  final AppPreferences _preferences;

  @override
  ObjectiveSort sort() => ObjectiveSort.values.firstWhere(
    (s) => s.name == _preferences.getString(PreferenceKey.objectiveSort),
    orElse: () => ObjectiveSort.manual,
  );

  @override
  Future<void> setSort(ObjectiveSort sort) => _preferences.setString(PreferenceKey.objectiveSort, sort.name);
}
