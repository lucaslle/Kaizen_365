# Kaizen 365

Application mobile de suivi d'objectifs annuels, en français. On fixe ses objectifs de l'année selon la méthode OKR (un objectif, 2 à 4 résultats clés), on suit sa progression au fil des check-ins et on clôture l'année avec un bilan.

Tout tourne sur le téléphone : aucune API externe, aucun compte, aucune donnée envoyée sur Internet.

## Fonctionnalités

- **Onboarding** en 3 étapes : présentation, méthode, prénom et rythme des check-ins.
- **Objectifs** : domaine de vie, motivation et résultats clés de trois types :
  - valeur chiffrée (de 0 à 900 km, par exemple) ;
  - pourcentage estimé ;
  - liste de jalons à cocher.
- **Statut automatique** de chaque objectif (Atteint, En bonne voie, À risque, En retard), calculé par rapport au temps écoulé dans l'année.
- **Check-ins** : chaque progression est journalisée automatiquement, et on peut ajouter un point libre avec une humeur.
- **Modification et suppression** d'un objectif, en conservant la progression et l'historique lors d'une modification.
- **Journal** de tous les check-ins, filtrable par objectif.
- **Bilan de l'année** : score, statistiques, report des objectifs non atteints, réflexions et clôture.
- **Rappels de check-in** par notifications locales : chaque semaine, un dimanche sur deux ou chaque mois.
- **Profil** : prénom, rythme des rappels et thème, modifiables à tout moment.
- **5 thèmes** : Sable, Nuit (sombre), Forêt, Océan et Lavande.

## Prérequis

- [Flutter](https://docs.flutter.dev/get-started/install) 3.41 ou plus récent (Dart 3.11).
- Android Studio avec le SDK Android 36, ou Xcode pour iOS.
- Un téléphone avec le débogage USB activé, ou un émulateur.

## Lancer l'application

```bash
flutter pub get
flutter run
```

Pour générer un APK installable :

```bash
flutter build apk --release
```

Le fichier est créé dans `build/app/outputs/flutter-apk/app-release.apk`.

## Tests

```bash
flutter analyze
flutter test
```

Le test `test/app/app_flow_test.dart` parcourt l'application de bout en bout : onboarding, création, mise à jour, check-in, journal, bilan, profil, thème, modification et suppression. Il compare chaque écran à une capture de référence, rangée dans `test/app/screenshots/`.

Après une modification visuelle volontaire, régénère les captures :

```bash
flutter test --update-goldens
```

## Architecture

Le code suit une organisation en couches (OSDD) avec Clean Architecture dans chaque couche fonctionnelle :

```text
lib/
  main.dart
  app/                      Assemblage : injection de dépendances, racine, navigation par onglets
  layers/
    technical/
      clock/                Horloge injectable
      localization/         Textes (flutter_localization) et formats français (intl)
      notifications/        Notifications locales programmées
      preferences/          Stockage clé-valeur (shared_preferences)
      theme/                Palettes, thèmes, styles de texte et composants réutilisables
    functional/
      objectives/           Objectifs, check-ins, journal et bilan
        domain/             Entités, contrats (gateways) et cas d'usage
        data/               Persistance JSON locale
        presentation/       Cubits, écrans et widgets
      profile/              Onboarding, réglages et rappels
```

- **État** : `flutter_bloc` (Cubit). La chaîne d'appel est Vue, puis Cubit, puis cas d'usage, puis gateway.
- **Injection de dépendances** : `get_it`.
- **Stockage** : les objectifs dans un fichier JSON du dossier de l'application ; les réglages et le bilan dans `shared_preferences`.
- **Polices** : Bricolage Grotesque et JetBrains Mono, embarquées dans l'application.
- **Icônes** : Material Symbols Rounded, embarquées elles aussi.
