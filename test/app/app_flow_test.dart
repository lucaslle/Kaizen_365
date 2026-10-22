import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:kaizen365/app/dependency_injection.dart';
import 'package:kaizen365/app/kaizen_app.dart';
import 'package:kaizen365/layers/functional/objectives/domain/entities/objective_sort.dart';
import 'package:kaizen365/layers/functional/objectives/domain/gateways/backup_gateway.dart';
import 'package:kaizen365/layers/functional/objectives/domain/gateways/objective_preferences_gateway.dart';
import 'package:kaizen365/layers/technical/localization/app_language.dart';
import 'package:kaizen365/layers/functional/objectives/domain/entities/objective.dart';
import 'package:kaizen365/layers/functional/objectives/domain/entities/year_review.dart';
import 'package:kaizen365/layers/functional/objectives/domain/gateways/objective_gateway.dart';
import 'package:kaizen365/layers/functional/objectives/domain/gateways/year_review_gateway.dart';
import 'package:kaizen365/layers/functional/profile/domain/entities/user_settings.dart';
import 'package:kaizen365/layers/functional/profile/domain/gateways/reminder_gateway.dart';
import 'package:kaizen365/layers/functional/profile/domain/gateways/settings_gateway.dart';

import '../layers/functional/profile/fake_reminder_gateway.dart';
import 'package:kaizen365/layers/technical/clock/clock.dart';
import 'package:kaizen365/layers/technical/localization/app_locale.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _MemoryObjectiveGateway implements ObjectiveGateway {
  final _changes = StreamController<List<Objective>>.broadcast();
  var _objectives = <Objective>[];

  @override
  Stream<List<Objective>> watch() async* {
    yield _objectives;
    yield* _changes.stream;
  }

  @override
  Future<void> save(Objective objective) async {
    _objectives = [..._objectives.where((o) => o.id != objective.id), objective];
    _changes.add(_objectives);
  }

  @override
  Future<void> delete(String objectiveId) async {
    _objectives = _objectives.where((o) => o.id != objectiveId).toList();
    _changes.add(_objectives);
  }

  @override
  Future<void> reorder(List<String> orderedIds) async {
    _objectives = [..._objectives]..sort((a, b) => orderedIds.indexOf(a.id).compareTo(orderedIds.indexOf(b.id)));
    _changes.add(_objectives);
  }

  @override
  Future<void> replaceAll(List<Objective> objectives) async {
    _objectives = objectives;
    _changes.add(_objectives);
  }
}

class _NoBackupGateway implements BackupGateway {
  @override
  Future<void> export() async {}

  @override
  Future<bool> import() async => false;
}

class _MemoryObjectivePreferences implements ObjectivePreferencesGateway {
  ObjectiveSort _sort = ObjectiveSort.manual;

  @override
  ObjectiveSort sort() => _sort;

  @override
  Future<void> setSort(ObjectiveSort sort) async => _sort = sort;
}

class _MemorySettingsGateway implements SettingsGateway {
  UserSettings settings = const UserSettings(languageCode: 'fr');

  @override
  UserSettings load() => settings;

  @override
  Future<void> save(UserSettings settings) async => this.settings = settings;
}

class _MemoryYearReviewGateway implements YearReviewGateway {
  final _reviews = <int, YearReview>{};
  final _yearChanges = StreamController<int>.broadcast();
  var _activeYear = 2026;

  @override
  int activeYear() => _activeYear;

  @override
  Stream<int> watchActiveYear() async* {
    yield _activeYear;
    yield* _yearChanges.stream;
  }

  @override
  Future<void> setActiveYear(int year) async {
    _activeYear = year;
    _yearChanges.add(year);
  }

  @override
  YearReview load(int year) => _reviews[year] ?? const YearReview();

  @override
  Future<void> save(int year, YearReview review) async => _reviews[year] = review;

  @override
  Map<int, YearReview> loadAll() => Map.of(_reviews);

  @override
  Future<void> replaceAll(Map<int, YearReview> reviews, {required int activeYear}) async {
    _reviews
      ..clear()
      ..addAll(reviews);
    await setActiveYear(activeYear);
  }
}

Future<void> _loadFont(String family, String asset) => (FontLoader(family)..addFont(rootBundle.load(asset))).load();

void main() {
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    Intl.defaultLocale = 'fr_FR';
    await initializeDateFormatting('fr_FR');
    await _loadFont('BricolageGrotesque', 'assets/fonts/bricolage_grotesque.ttf');
    await _loadFont('JetBrainsMono', 'assets/fonts/jetbrains_mono.ttf');
    await _loadFont(
      'packages/material_symbols_icons/MaterialSymbolsRounded',
      'packages/material_symbols_icons/lib/fonts/MaterialSymbolsRounded.ttf',
    );
    final localization = FlutterLocalization.instance;
    await localization.ensureInitialized();
    localization.init(
      mapLocales: [const MapLocale('fr', AppLocale.fr), const MapLocale('en', AppLocale.en)],
      initLanguageCode: 'fr',
    );
    AppLanguage.apply('fr');
    final getIt = GetIt.instance
      ..registerSingleton<Clock>(() => DateTime(2026, 10, 13, 9))
      ..registerSingleton<ObjectiveGateway>(_MemoryObjectiveGateway())
      ..registerSingleton<SettingsGateway>(_MemorySettingsGateway())
      ..registerSingleton<YearReviewGateway>(_MemoryYearReviewGateway())
      ..registerSingleton<ReminderGateway>(FakeReminderGateway())
      ..registerSingleton<BackupGateway>(_NoBackupGateway())
      ..registerSingleton<ObjectivePreferencesGateway>(_MemoryObjectivePreferences());
    registerUseCases(getIt);
  });

  testWidgets('onboarding, creating an objective and updating it', (tester) async {
    tester.view
      ..physicalSize = const Size(412 * 2, 892 * 2)
      ..devicePixelRatio = 2;
    addTearDown(tester.view.reset);
    Future<void> shot(String name) => expectLater(find.byType(MaterialApp), matchesGoldenFile('screenshots/$name.png'));
    Future<void> tap(String text) async {
      await tester.ensureVisible(find.text(text).last);
      await tester.tap(find.text(text).last);
      await tester.pumpAndSettle();
    }

    await tester.pumpWidget(const KaizenApp());
    await tester.pumpAndSettle();
    await shot('01_onboarding');
    await tap('Continuer');
    await shot('02_onboarding_steps');
    await tap('Continuer');
    await tester.enterText(find.byType(TextField), 'Camille');
    await tester.pumpAndSettle();
    await shot('03_onboarding_profile');
    await tap('Commencer mon année');
    await shot('04_home_empty');

    await tap('Créer mon premier objectif');
    await tester.enterText(find.byType(TextField), 'Courir un semi-marathon');
    await tester.pumpAndSettle();
    await shot('05_wizard_what');
    await tap('Suivant');
    await tap('Passer');
    await tester.enterText(find.byType(TextField).at(0), 'Kilomètres courus');
    await tester.enterText(find.byType(TextField).at(2), '900');
    await tester.enterText(find.byType(TextField).at(3), 'km');
    await tester.pumpAndSettle();
    await tap('Ajouter ce résultat clé');
    await shot('06_wizard_key_results');
    await tap('Suivant');
    await shot('07_wizard_recap');
    await tap("Créer l'objectif");
    expect(find.text('Objectif créé'), findsOneWidget);
    await shot('08_detail');

    await tap('Mettre à jour');
    await tester.tap(find.byTooltip('Augmenter'));
    await tester.pumpAndSettle();
    await shot('09_update_sheet');
    await tap('Enregistrer');
    expect(find.text('Kilomètres courus : 0 → 10 km'), findsOneWidget);

    await tester.tap(find.byTooltip('Supprimer ce check-in').first);
    await tester.pumpAndSettle();
    await tap('Supprimer');
    expect(find.text('Kilomètres courus : 0 → 10 km'), findsNothing);
    expect(find.text('0 / 900 km'), findsOneWidget);
    await tap('Mettre à jour');
    await tester.tap(find.byTooltip('Augmenter'));
    await tester.pumpAndSettle();
    await tap('Enregistrer');
    expect(find.text('10 / 900 km'), findsOneWidget);

    await tap('Nouveau');
    await tester.enterText(find.byType(TextField), 'Première sortie de 10 km.');
    await tester.pumpAndSettle();
    await shot('10_checkin_sheet');
    await tap('Publier le check-in');
    await tester.tap(find.byTooltip('Retour'));
    await tester.pumpAndSettle();
    await shot('11_home');
    await tap('Journal');
    await shot('12_journal');
    await tester.enterText(find.byType(TextField), 'sortie');
    await tester.pumpAndSettle();
    expect(find.text('Première sortie de 10 km.'), findsOneWidget);
    expect(find.text('Kilomètres courus : 0 → 10 km'), findsNothing);
    await tester.tap(find.byTooltip('Effacer la recherche'));
    await tester.pumpAndSettle();
    await tap('Bilan');
    await shot('13_review');

    await tap('Objectifs');
    await tester.tap(find.byTooltip('Ouvrir mon profil'));
    await tester.pumpAndSettle();
    await tap('Toutes les 2 semaines');
    await shot('14_profile');
    await tester.scrollUntilVisible(find.text('English'), 300, scrollable: find.byType(Scrollable).first);
    await tap('English');
    expect(find.text('PROFILE'), findsOneWidget);
    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();
    expect(find.text('My 2026 goals'), findsOneWidget);
    await shot('14b_home_english');
    await tester.tap(find.byTooltip('Open my profile'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('Français'), 300, scrollable: find.byType(Scrollable).first);
    await tap('Français');
    await tester.scrollUntilVisible(find.bySemanticsLabel('Nuit'), -300, scrollable: find.byType(Scrollable).first);
    await tester.tap(find.bySemanticsLabel('Nuit'));
    await tester.pumpAndSettle();
    await shot('15_profile_night');
    await tester.tap(find.byTooltip('Retour'));
    await tester.pumpAndSettle();
    await shot('16_home_night');
    await tap('Bilan');
    await shot('17_review_night');

    final reviewList = find.ancestor(of: find.text('Objectif par objectif'), matching: find.byType(Scrollable)).first;
    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();
    await tester.fling(reviewList, const Offset(0, -3000), 4000);
    await tester.pumpAndSettle();
    await tap('Clôturer 2026');
    expect(find.text('2026 est clôturée.'), findsOneWidget);
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
    await tester.fling(reviewList, const Offset(0, -3000), 4000);
    await tester.pumpAndSettle();
    await tap('Passer à 2027');
    expect(find.text('Nouvelle année lancée avec 1 objectif reporté.'), findsOneWidget);
    expect(find.text('Mes objectifs 2027'), findsOneWidget);
    await shot('18_home_2027');
    await tap('Courir un semi-marathon');
    await tester.tap(find.byTooltip("Modifier l'objectif"));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Courir le semi de Lyon');
    await tester.pumpAndSettle();
    await tap('Suivant');
    await tap('Passer');
    await tester.tap(find.byTooltip('Modifier Kilomètres courus'));
    await tester.pumpAndSettle();
    await shot('19_edit_key_result');
    await tap('Enregistrer ce résultat clé');
    await tap('Suivant');
    await tap('Enregistrer');
    expect(find.text('Objectif modifié'), findsOneWidget);
    expect(find.text('Reporté depuis 2026, avec sa progression.'), findsOneWidget);
    expect(find.text('Courir le semi de Lyon'), findsOneWidget);
    expect(find.text('10 / 900 km'), findsOneWidget);

    await tester.tap(find.byTooltip("Supprimer l'objectif"));
    await tester.pumpAndSettle();
    await shot('20_delete_confirm');
    await tap('Supprimer');
    expect(find.text('Objectif supprimé'), findsOneWidget);
    expect(find.text("Aucun cap pour l'instant"), findsOneWidget);
    await tap('Annuler');
    expect(find.text('Courir le semi de Lyon'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
