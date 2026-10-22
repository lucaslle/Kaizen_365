import 'dart:convert';

import '../../../../technical/clock/clock.dart';
import '../../../../technical/files/file_exchange.dart';
import '../../../profile/domain/entities/user_settings.dart';
import '../../../profile/domain/gateways/settings_gateway.dart';
import '../../domain/gateways/backup_gateway.dart';
import '../../domain/gateways/objective_gateway.dart';
import '../../domain/gateways/year_review_gateway.dart';
import '../models/objective_dto.dart';
import '../models/year_review_dto.dart';

class BackupGatewayImpl implements BackupGateway {
  BackupGatewayImpl(this._objectives, this._years, this._settings, this._files, this._clock);

  static const _format = 'kaizen365-backup';
  static const _version = 1;

  final ObjectiveGateway _objectives;
  final YearReviewGateway _years;
  final SettingsGateway _settings;
  final FileExchange _files;
  final Clock _clock;

  @override
  Future<void> export() async {
    final now = _clock();
    final settings = _settings.load();
    final backup = {
      'format': _format,
      'version': _version,
      'exportedAt': now.toIso8601String(),
      'activeYear': _years.activeYear(),
      'objectives': [for (final o in await _objectives.watch().first) ObjectiveDto.toJson(o)],
      'yearReviews': {
        for (final MapEntry(:key, :value) in _years.loadAll().entries) '$key': YearReviewDto.toJson(value),
      },
      'settings': {
        'name': settings.name,
        'rhythm': settings.rhythm.name,
        'themeName': settings.themeName,
        'languageCode': settings.languageCode,
        'reminderMinutes': settings.reminderMinutes,
        'areRemindersEnabled': settings.areRemindersEnabled,
      },
    };
    final date = now.toIso8601String().substring(0, 10);
    await _files.share('kaizen365-$date.json', const JsonEncoder.withIndent('  ').convert(backup));
  }

  @override
  Future<bool> import() async {
    final content = await _files.pickText();
    if (content == null) return false;
    final Map<String, dynamic> backup;
    try {
      backup = jsonDecode(content) as Map<String, dynamic>;
    } on Object {
      throw const FormatException('Not JSON');
    }
    if (backup['format'] != _format || backup['version'] != _version) throw const FormatException('Not a backup');
    final objectives = [for (final o in backup['objectives'] as List) ObjectiveDto.fromJson(o as Map<String, dynamic>)];
    final reviews = {
      for (final MapEntry(:key, :value) in (backup['yearReviews'] as Map<String, dynamic>).entries)
        int.parse(key): YearReviewDto.fromJson(value as Map<String, dynamic>),
    };
    final settings = backup['settings'] as Map<String, dynamic>;
    final restoredSettings = UserSettings(
      name: settings['name'] as String,
      rhythm: CheckinRhythm.values.byName(settings['rhythm'] as String),
      themeName: settings['themeName'] as String,
      languageCode: settings['languageCode'] as String,
      reminderMinutes: settings['reminderMinutes'] as int,
      areRemindersEnabled: settings['areRemindersEnabled'] as bool,
      hasCompletedOnboarding: true,
    );
    final activeYear = backup['activeYear'] as int;
    await _objectives.replaceAll(objectives);
    await _years.replaceAll(reviews, activeYear: activeYear);
    await _settings.save(restoredSettings);
    return true;
  }
}
