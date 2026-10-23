import 'package:get_it/get_it.dart';

import '../layers/functional/objectives/domain/entities/checkin.dart';
import '../layers/functional/objectives/domain/entities/key_result.dart';
import '../layers/functional/objectives/domain/entities/life_domain.dart';
import '../layers/functional/objectives/domain/entities/milestone.dart';
import '../layers/functional/objectives/domain/entities/mood.dart';
import '../layers/functional/objectives/domain/entities/objective.dart';
import '../layers/functional/objectives/domain/entities/progress_change.dart';
import '../layers/functional/objectives/domain/gateways/objective_gateway.dart';
import '../layers/technical/preferences/app_preferences.dart';

/// Builds with `--dart-define=KAIZEN_DEMO=true` (the web demo) start with sample objectives.
abstract final class DemoSeed {
  static const isEnabled = bool.fromEnvironment('KAIZEN_DEMO');

  static Future<void> seedOnce(String languageCode) async {
    final preferences = GetIt.I<AppPreferences>();
    if (!isEnabled || (preferences.getBool(PreferenceKey.isDemoSeeded) ?? false)) return;
    final gateway = GetIt.I<ObjectiveGateway>();
    for (final objective in _objectives(DateTime.now(), isEnglish: languageCode == 'en')) {
      await gateway.save(objective);
    }
    await preferences.setBool(PreferenceKey.isDemoSeeded, true);
  }

  static List<Objective> _objectives(DateTime now, {required bool isEnglish}) {
    String t(String fr, String en) => isEnglish ? en : fr;
    DateTime ago(int days) => now.subtract(Duration(days: days));
    final year = now.year;
    Checkin created(String id) => Checkin(
      id: 'c-$id-0',
      date: DateTime(year, 1, 6),
      mood: Mood.up,
      change: const ProgressChange(kind: ProgressChangeKind.created),
    );
    return [
      Objective(
        id: 'demo-run',
        title: t('Courir un semi-marathon', 'Run a half marathon'),
        domain: LifeDomain.health,
        year: year,
        why: t(
          'Me prouver que je peux tenir une discipline sur la durée.',
          'Prove to myself I can keep a discipline over time.',
        ),
        keyResults: [
          KeyResult(
            id: 'km',
            title: t('Kilomètres courus', 'Kilometres run'),
            type: KeyResultType.numeric,
            value: 640,
            target: 900,
            unit: 'km',
            step: 10,
          ),
          KeyResult(
            id: 'plan',
            title: t("Plan d'entraînement", 'Training plan'),
            type: KeyResultType.milestones,
            milestones: [
              Milestone(title: t('Courir 10 km sans pause', 'Run 10 km non-stop'), isDone: true),
              Milestone(title: t("S'inscrire au semi de Lyon", 'Sign up for the Lyon half'), isDone: true),
              Milestone(title: t('Sortie longue de 18 km', 'Long run of 18 km'), isDone: true),
              Milestone(title: t('Finir le semi', 'Finish the half')),
            ],
          ),
          KeyResult(
            id: 'sessions',
            title: t('Séances réalisées vs prévues', 'Sessions done vs planned'),
            type: KeyResultType.percent,
            value: 70,
          ),
        ],
        checkins: [
          Checkin(
            id: 'c-run-2',
            date: ago(7),
            mood: Mood.up,
            text: t(
              'Sortie longue de 18 km bouclée en 1h52. Les jambes ont tenu !',
              '18 km long run done in 1h52. The legs held up!',
            ),
            change: ProgressChange(
              kind: ProgressChangeKind.milestoneDone,
              subject: t('Sortie longue de 18 km', 'Long run of 18 km'),
              keyResultId: 'plan',
            ),
          ),
          Checkin(
            id: 'c-run-1',
            date: ago(21),
            mood: Mood.mid,
            text: t(
              "Petite douleur au genou, j'ai levé le pied cette semaine.",
              'A bit of knee pain, I eased off this week.',
            ),
            change: ProgressChange(
              kind: ProgressChangeKind.value,
              subject: t('Kilomètres courus', 'Kilometres run'),
              from: 590,
              to: 640,
              unit: 'km',
              keyResultId: 'km',
            ),
          ),
          created('run'),
        ],
      ),
      Objective(
        id: 'demo-read',
        title: t('Lire 24 livres', 'Read 24 books'),
        domain: LifeDomain.wellBeing,
        year: year,
        why: t('Retrouver le plaisir de lire, loin des écrans.', 'Rediscover the joy of reading, away from screens.'),
        keyResults: [
          KeyResult(
            id: 'books',
            title: t('Livres terminés', 'Books finished'),
            type: KeyResultType.numeric,
            value: 15,
            target: 24,
            unit: t('livres', 'books'),
          ),
          KeyResult(
            id: 'notes',
            title: t('Fiches de lecture rédigées', 'Reading notes written'),
            type: KeyResultType.percent,
            value: 55,
          ),
        ],
        checkins: [
          Checkin(
            id: 'c-read-1',
            date: ago(14),
            mood: Mood.mid,
            text: t(
              'Mois chargé, un seul livre fini. Je garde un livre dans mon sac.',
              'Busy month, only one book finished. I keep a book in my bag now.',
            ),
          ),
          created('read'),
        ],
      ),
      Objective(
        id: 'demo-save',
        title: t('Épargner 6 000 €', 'Save €6,000'),
        domain: LifeDomain.finances,
        year: year,
        why: t('Financer un voyage au Japon sans crédit.', 'Pay for a trip to Japan without a loan.'),
        keyResults: [
          KeyResult(
            id: 'saved',
            title: t('Montant épargné', 'Amount saved'),
            type: KeyResultType.numeric,
            value: 4900,
            target: 6000,
            unit: '€',
            step: 100,
          ),
          KeyResult(
            id: 'budget',
            title: t('Mettre en place le budget', 'Set up the budget'),
            type: KeyResultType.milestones,
            milestones: [
              Milestone(title: t('Ouvrir un livret dédié', 'Open a dedicated savings account'), isDone: true),
              Milestone(
                title: t('Virement automatique de 500 €/mois', 'Automatic €500 monthly transfer'),
                isDone: true,
              ),
              Milestone(title: t('Résilier 2 abonnements inutiles', 'Cancel 2 useless subscriptions'), isDone: true),
            ],
          ),
        ],
        checkins: [
          Checkin(
            id: 'c-save-1',
            date: ago(12),
            mood: Mood.up,
            text: t('Virement du mois passé, on approche du but.', "This month's transfer is done, getting close."),
            change: ProgressChange(
              kind: ProgressChangeKind.value,
              subject: t('Montant épargné', 'Amount saved'),
              from: 4400,
              to: 4900,
              unit: '€',
              keyResultId: 'saved',
            ),
          ),
          created('save'),
        ],
      ),
      Objective(
        id: 'demo-spanish',
        title: t('Parler espagnol niveau B1', 'Speak Spanish at B1 level'),
        domain: LifeDomain.learning,
        year: year,
        why: t(
          'Pouvoir discuter avec la famille de Lucía sans traducteur.',
          "Talk with Lucía's family without a translator.",
        ),
        keyResults: [
          KeyResult(
            id: 'lessons',
            title: t('Leçons complétées', 'Lessons completed'),
            type: KeyResultType.numeric,
            value: 42,
            target: 120,
            unit: t('leçons', 'lessons'),
          ),
          KeyResult(
            id: 'steps',
            title: t('Étapes vers le B1', 'Steps to B1'),
            type: KeyResultType.milestones,
            milestones: [
              Milestone(title: t('Réussir le test A2', 'Pass the A2 test'), isDone: true),
              Milestone(title: t('Une conversation de 15 min', 'A 15-minute conversation')),
              Milestone(title: t('Une série sans sous-titres', 'A series without subtitles')),
              Milestone(title: t('Passer le DELE B1', 'Take the DELE B1')),
            ],
          ),
        ],
        checkins: [
          Checkin(
            id: 'c-es-1',
            date: ago(28),
            mood: Mood.down,
            text: t(
              'Du mal à trouver le temps le soir. Essayer 15 min le matin ?',
              'Hard to find time in the evening. Try 15 min in the morning?',
            ),
          ),
          created('spanish'),
        ],
      ),
    ];
  }
}
