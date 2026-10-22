import 'dart:async';
import 'dart:convert';

import '../../../../technical/clock/clock.dart';
import '../../../../technical/preferences/app_preferences.dart';
import '../../domain/entities/year_review.dart';
import '../../domain/gateways/year_review_gateway.dart';
import '../models/year_review_dto.dart';

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
    if (stored != null) return YearReviewDto.fromJson(stored as Map<String, dynamic>);
    return year == activeYear() ? _legacyReview() : const YearReview();
  }

  @override
  Future<void> save(int year, YearReview review) => _preferences.setString(
    PreferenceKey.yearReviews,
    jsonEncode({..._reviews(), '$year': YearReviewDto.toJson(review)}),
  );

  @override
  Map<int, YearReview> loadAll() => {
    for (final MapEntry(:key, :value) in _reviews().entries)
      int.parse(key): YearReviewDto.fromJson(value as Map<String, dynamic>),
  };

  @override
  Future<void> replaceAll(Map<int, YearReview> reviews, {required int activeYear}) async {
    await _preferences.setString(
      PreferenceKey.yearReviews,
      jsonEncode({for (final MapEntry(:key, :value) in reviews.entries) '$key': YearReviewDto.toJson(value)}),
    );
    await setActiveYear(activeYear);
  }

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
}
