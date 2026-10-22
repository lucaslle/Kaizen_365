import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:kaizen365/app/kaizen_app.dart';
import 'package:kaizen365/layers/functional/objectives/domain/entities/objective.dart';
import 'package:kaizen365/layers/functional/objectives/domain/entities/year_review.dart';
import 'package:kaizen365/layers/functional/objectives/domain/gateways/objective_gateway.dart';
import 'package:kaizen365/layers/functional/objectives/domain/gateways/year_review_gateway.dart';
import 'package:kaizen365/layers/functional/objectives/domain/use_cases/add_checkin_use_case.dart';
import 'package:kaizen365/layers/functional/objectives/domain/use_cases/create_objective_use_case.dart';
import 'package:kaizen365/layers/functional/objectives/domain/use_cases/delete_objective_use_case.dart';
import 'package:kaizen365/layers/functional/objectives/domain/use_cases/get_year_review_use_case.dart';
import 'package:kaizen365/layers/functional/objectives/domain/use_cases/save_year_review_use_case.dart';
import 'package:kaizen365/layers/functional/objectives/domain/use_cases/toggle_milestone_use_case.dart';
import 'package:kaizen365/layers/functional/objectives/domain/use_cases/update_objective_use_case.dart';
import 'package:kaizen365/layers/functional/objectives/domain/use_cases/update_key_result_use_case.dart';
import 'package:kaizen365/layers/functional/objectives/domain/use_cases/watch_objectives_use_case.dart';
import 'package:kaizen365/layers/functional/profile/domain/entities/user_settings.dart';
import 'package:kaizen365/layers/functional/profile/domain/gateways/reminder_gateway.dart';
import 'package:kaizen365/layers/functional/profile/domain/gateways/settings_gateway.dart';
import 'package:kaizen365/layers/functional/profile/domain/use_cases/complete_onboarding_use_case.dart';
import 'package:kaizen365/layers/functional/profile/domain/use_cases/get_settings_use_case.dart';
import 'package:kaizen365/layers/functional/profile/domain/use_cases/schedule_checkin_reminders_use_case.dart';
import 'package:kaizen365/layers/functional/profile/domain/use_cases/update_settings_use_case.dart';

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
}

class _MemorySettingsGateway implements SettingsGateway {
  UserSettings settings = const UserSettings();

  @override
  UserSettings load() => settings;

  @override
  Future<void> save(UserSettings settings) async => this.settings = settings;
}

class _MemoryYearReviewGateway implements YearReviewGateway {
  YearReview review = const YearReview();

  @override
  YearReview load() => review;

  @override
  Future<void> save(YearReview review) async => this.review = review;
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
    localization.init(mapLocales: [const MapLocale('fr', AppLocale.fr)], initLanguageCode: 'fr');
    final getIt = GetIt.instance
      ..registerSingleton<Clock>(() => DateTime(2026, 10, 13, 9))
      ..registerSingleton<ObjectiveGateway>(_MemoryObjectiveGateway())
      ..registerSingleton<SettingsGateway>(_MemorySettingsGateway())
      ..registerSingleton<YearReviewGateway>(_MemoryYearReviewGateway())
      ..registerSingleton<ReminderGateway>(FakeReminderGateway());
    getIt
      ..registerLazySingleton(() => WatchObjectivesUseCase(getIt()))
      ..registerLazySingleton(() => CreateObjectiveUseCase(getIt(), getIt()))
      ..registerLazySingleton(() => UpdateObjectiveUseCase(getIt()))
      ..registerLazySingleton(() => DeleteObjectiveUseCase(getIt()))
      ..registerLazySingleton(() => AddCheckinUseCase(getIt(), getIt()))
      ..registerLazySingleton(() => ToggleMilestoneUseCase(getIt(), getIt()))
      ..registerLazySingleton(() => UpdateKeyResultUseCase(getIt(), getIt()))
      ..registerLazySingleton(() => GetYearReviewUseCase(getIt()))
      ..registerLazySingleton(() => SaveYearReviewUseCase(getIt()))
      ..registerLazySingleton(() => GetSettingsUseCase(getIt()))
      ..registerLazySingleton(() => ScheduleCheckinRemindersUseCase(getIt(), getIt()))
      ..registerLazySingleton(() => CompleteOnboardingUseCase(getIt(), getIt(), getIt()))
      ..registerLazySingleton(() => UpdateSettingsUseCase(getIt(), getIt(), getIt()));
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
    await tap('Bilan');
    await shot('13_review');

    await tap('Objectifs');
    await tester.tap(find.byTooltip('Ouvrir mon profil'));
    await tester.pumpAndSettle();
    await tap('Toutes les 2 semaines');
    await shot('14_profile');
    await tester.tap(find.bySemanticsLabel('Nuit'));
    await tester.pumpAndSettle();
    await shot('15_profile_night');
    await tester.tap(find.byTooltip('Retour'));
    await tester.pumpAndSettle();
    await shot('16_home_night');
    await tap('Bilan');
    await shot('17_review_night');

    await tap('Objectifs');
    await tap('Courir un semi-marathon');
    await tester.tap(find.byTooltip("Modifier l'objectif"));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Courir le semi de Lyon');
    await tester.pumpAndSettle();
    await tap('Suivant');
    await tap('Passer');
    await tester.tap(find.byTooltip('Modifier Kilomètres courus'));
    await tester.pumpAndSettle();
    await shot('18_edit_key_result');
    await tap('Enregistrer ce résultat clé');
    await tap('Suivant');
    await tap('Enregistrer');
    expect(find.text('Objectif modifié'), findsOneWidget);
    expect(find.text('Courir le semi de Lyon'), findsOneWidget);
    expect(find.text('10 / 900 km'), findsOneWidget);

    await tester.tap(find.byTooltip("Supprimer l'objectif"));
    await tester.pumpAndSettle();
    await shot('19_delete_confirm');
    await tap('Supprimer');
    expect(find.text('Objectif supprimé'), findsOneWidget);
    expect(find.text("Aucun cap pour l'instant"), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
