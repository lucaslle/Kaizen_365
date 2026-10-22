import '../../../../technical/preferences/app_preferences.dart';
import '../../domain/entities/year_review.dart';
import '../../domain/gateways/year_review_gateway.dart';

class YearReviewGatewayImpl implements YearReviewGateway {
  YearReviewGatewayImpl(this._preferences);

  final AppPreferences _preferences;

  static const _reflectionKeys = {
    Reflection.proud: PreferenceKey.reflectionProud,
    Reflection.learned: PreferenceKey.reflectionLearned,
    Reflection.next: PreferenceKey.reflectionNext,
  };

  @override
  YearReview load() => YearReview(
    isClosed: _preferences.getBool(PreferenceKey.isYearClosed) ?? false,
    carriedObjectiveIds: {...?_preferences.getStringList(PreferenceKey.carriedObjectiveIds)},
    reflections: {
      for (final MapEntry(:key, :value) in _reflectionKeys.entries) key: _preferences.getString(value) ?? '',
    },
  );

  @override
  Future<void> save(YearReview review) async {
    await _preferences.setBool(PreferenceKey.isYearClosed, review.isClosed);
    await _preferences.setStringList(PreferenceKey.carriedObjectiveIds, review.carriedObjectiveIds.toList());
    for (final MapEntry(:key, :value) in _reflectionKeys.entries) {
      await _preferences.setString(value, review.reflections[key] ?? '');
    }
  }
}
