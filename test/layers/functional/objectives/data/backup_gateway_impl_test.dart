import 'package:flutter_test/flutter_test.dart';
import 'package:kaizen365/layers/functional/objectives/data/gateways/backup_gateway_impl.dart';
import 'package:kaizen365/layers/functional/objectives/domain/entities/key_result.dart';
import 'package:kaizen365/layers/functional/objectives/domain/entities/life_domain.dart';
import 'package:kaizen365/layers/functional/objectives/domain/entities/objective.dart';
import 'package:kaizen365/layers/functional/objectives/domain/entities/year_review.dart';
import 'package:kaizen365/layers/functional/objectives/domain/gateways/year_review_gateway.dart';
import 'package:kaizen365/layers/functional/profile/domain/entities/user_settings.dart';
import 'package:kaizen365/layers/functional/profile/domain/gateways/settings_gateway.dart';
import 'package:kaizen365/layers/technical/files/file_exchange.dart';

import '../fake_objective_gateway.dart';

class _MemoryFiles implements FileExchange {
  String? shared;
  String? toPick;

  @override
  Future<void> share(String fileName, String content) async => shared = content;

  @override
  Future<String?> pickText() async => toPick;
}

class _Years implements YearReviewGateway {
  var reviews = <int, YearReview>{};
  var active = 2026;

  @override
  int activeYear() => active;

  @override
  Stream<int> watchActiveYear() => Stream.value(active);

  @override
  Future<void> setActiveYear(int year) async => active = year;

  @override
  YearReview load(int year) => reviews[year] ?? const YearReview();

  @override
  Future<void> save(int year, YearReview review) async => reviews[year] = review;

  @override
  Map<int, YearReview> loadAll() => reviews;

  @override
  Future<void> replaceAll(Map<int, YearReview> reviews, {required int activeYear}) async {
    this.reviews = reviews;
    active = activeYear;
  }
}

class _Settings implements SettingsGateway {
  UserSettings settings = const UserSettings();

  @override
  UserSettings load() => settings;

  @override
  Future<void> save(UserSettings settings) async => this.settings = settings;
}

void main() {
  test('an export restores everything on another phone', () async {
    final files = _MemoryFiles();
    final source = FakeObjectiveGateway();
    await source.save(
      const Objective(
        id: 'o1',
        title: 'Lire',
        domain: LifeDomain.wellBeing,
        year: 2026,
        keyResults: [KeyResult(id: 'k', title: 'Livres', type: KeyResultType.numeric, value: 12, target: 24)],
      ),
    );
    final sourceYears = _Years()
      ..reviews = {
        2026: const YearReview(isClosed: true, carriedObjectiveIds: {'o1'}),
      }
      ..active = 2027;
    final sourceSettings = _Settings()
      ..settings = const UserSettings(
        name: 'Lucas',
        themeName: 'night',
        reminderMinutes: 600,
        hasCompletedOnboarding: true,
      );
    await BackupGatewayImpl(source, sourceYears, sourceSettings, files, () => DateTime(2026, 12, 31)).export();

    final target = FakeObjectiveGateway();
    final targetYears = _Years();
    final targetSettings = _Settings();
    files.toPick = files.shared;
    final isImported = await BackupGatewayImpl(target, targetYears, targetSettings, files, DateTime.now).import();

    expect(isImported, isTrue);
    expect(target.saved.single.keyResults.single.value, 12);
    expect((targetYears.active, targetYears.reviews[2026]!.isClosed), (2027, true));
    expect((targetSettings.settings.name, targetSettings.settings.reminderMinutes), ('Lucas', 600));
    expect(targetSettings.settings.hasCompletedOnboarding, isTrue);
  });

  test('a file that is not a backup is refused and changes nothing', () async {
    final files = _MemoryFiles()..toPick = '{"hello": "world"}';
    final objectives = FakeObjectiveGateway();
    await objectives.save(const Objective(id: 'keep', title: 'Garder', domain: LifeDomain.health, year: 2026));
    final gateway = BackupGatewayImpl(objectives, _Years(), _Settings(), files, DateTime.now);
    await expectLater(gateway.import(), throwsFormatException);
    files.toPick = 'not json';
    await expectLater(gateway.import(), throwsFormatException);
    expect(objectives.saved.single.id, 'keep');
    files.toPick = null;
    expect(await gateway.import(), isFalse);
  });
}
