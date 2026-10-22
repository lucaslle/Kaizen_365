import 'dart:async';
import 'dart:convert';

import '../../../../technical/clock/clock.dart';
import '../../../../technical/preferences/app_preferences.dart';
import '../../domain/entities/year_review.dart';
import '../../domain/gateways/year_review_gateway.dart';

class YearReviewGatewayImpl implements YearReviewGateway {
  YearReviewGatewayImpl(this._preferences, this._clock);

  final AppPreferences _preferences;
  final Clock _clock;
  final _activeYearChanges = StreamController<int>.broadcast();

  static const _legacyReflectionKeys = {
    Reflection.proud: PreferenceKey.reflectionProud,
    Reflection.learned: PreferenceKey.reflectionLearned,
    Reflection.next: PreferenceKey.reflectionNext,
  };

  @override
  int activeYear() => _preferences.getInt(PreferenceKey.activeYear) ?? _clock().year;

  @override
  Stream<int> watchActiveYear() async* {
    yield activeYear();
    yield* _activeYearChanges.stream;
  }

  @override
  Future<void> setActiveYear(int year) async {
    await _preferences.setInt(PreferenceKey.activeYear, year);
    _activeYearChanges.add(year);
  }

  @override
  YearReview load(int year) {
    final stored = _reviews()['$year'];
    if (stored != null) return _fromJson(stored as Map<String, dynamic>);
    return year == activeYear() ? _legacyReview() : const YearReview();
  }

  @override
  Future<void> save(int year, YearReview review) =>
      _preferences.setString(PreferenceKey.yearReviews, jsonEncode({..._reviews(), '$year': _toJson(review)}));

  Map<String, dynamic> _reviews() {
    final raw = _preferences.getString(PreferenceKey.yearReviews);
    return raw == null ? {} : jsonDecode(raw) as Map<String, dynamic>;
  }

  /// Reviews saved before years were tracked used one flat set of keys.
  YearReview _legacyReview() => YearReview(
    isClosed: _preferences.getBool(PreferenceKey.isYearClosed) ?? false,
    carriedObjectiveIds: {...?_preferences.getStringList(PreferenceKey.carriedObjectiveIds)},
    reflections: {
      for (final MapEntry(:key, :value) in _legacyReflectionKeys.entries) key: _preferences.getString(value) ?? '',
    },
  );

  static Map<String, dynamic> _toJson(YearReview review) => {
    'isClosed': review.isClosed,
    'carriedObjectiveIds': review.carriedObjectiveIds.toList(),
    'reflections': {for (final MapEntry(:key, :value) in review.reflections.entries) key.name: value},
  };

  static YearReview _fromJson(Map<String, dynamic> json) => YearReview(
    isClosed: json['isClosed'] as bool,
    carriedObjectiveIds: {...(json['carriedObjectiveIds'] as List).cast<String>()},
    reflections: {
      for (final MapEntry(:key, :value) in (json['reflections'] as Map<String, dynamic>).entries)
        Reflection.values.byName(key): value as String,
    },
  );
}
