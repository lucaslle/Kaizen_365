# Kaizen 365

Application mobile de suivi d'objectifs annuels, en français. On fixe ses objectifs de l'année selon la méthode OKR (un objectif, 2 à 4 résultats clés), on suit sa progression au fil des check-ins et on clôture l'année avec un bilan.

Tout tourne sur le téléphone : aucune API externe, aucun compte, aucune donnée envoyée sur Internet.

**Démo en ligne : [lucaslle.github.io/Kaizen_365](https://lucaslle.github.io/Kaizen_365/)**. Sur ordinateur, l'application s'affiche dans un cadre d'iPhone ; sur téléphone, elle occupe tout l'écran. Des objectifs d'exemple sont déjà remplis et les données restent dans le navigateur.

## Fonctionnalités

- **Onboarding** en 3 étapes : présentation, méthode, prénom et rythme des check-ins.
- **Objectifs** : domaine de vie, motivation et résultats clés de trois types :
  - valeur chiffrée (de 0 à 900 km, par exemple) ;
  - pourcentage estimé ;
  - liste de jalons à cocher.
- **Statut automatique** de chaque objectif (Atteint, En bonne voie, À risque, En retard), calculé par rapport au temps écoulé dans l'année.
- **Check-ins** : chaque progression est journalisée automatiquement, et on peut ajouter un point libre avec une humeur.
- **Graphique d'évolution** de chaque objectif, comparé à la progression attendue.
- **Modification et suppression** d'un objectif. La progression et l'historique sont conservés lors d'une modification, et une suppression s'annule pendant quelques secondes.
- **Suppression d'un check-in**, qui annule la progression qu'il avait enregistrée.
- **Célébration** quand un objectif est atteint.
- **Accueil réordonnable** (appui long) ou trié par statut ou par progression.
- **Journal** de tous les check-ins, filtrable par objectif et avec recherche.
- **Bilan de l'année** : score, statistiques, report des objectifs non atteints, réflexions et clôture.
- **Passage à l'année suivante** : les objectifs reportés sont recopiés avec leur progression. Les bilans des années passées restent consultables.
- **Rappels de check-in** par notifications locales : chaque semaine, un dimanche sur deux ou chaque mois, à l'heure choisie. Toucher un rappel ouvre directement le check-in.
- **Widget d'écran d'accueil Android** : score de l'année, temps écoulé et prochain rappel.
- **Profil** : prénom, rappels (activation, heure, rythme), thème et langue.
- **6 thèmes** : Automatique (suit le mode sombre du téléphone), Sable, Nuit, Forêt, Océan et Lavande.
- **Français et anglais**, selon la langue du téléphone ou au choix.
- **Sauvegarde** : export de toutes les données dans un fichier JSON (via le partage du téléphone), puis restauration sur un autre appareil.

## Prérequis

- [Flutter](https://docs.flutter.dev/get-started/install) 3.41 ou plus récent (Dart 3.11).
- Android Studio avec le SDK Android 36, ou Xcode pour iOS.
- Un téléphone avec le débogage USB activé, ou un émulateur.

## Lancer l'application

```bash
flutter pub get
flutter run
```

Pour générer les APK installables, un par architecture de processeur (environ 20 Mo chacun, contre 52 Mo pour un APK universel) :

```bash
flutter build apk --release --split-per-abi
```

Sur un téléphone récent, installe `build/app/outputs/flutter-apk/app-arm64-v8a-release.apk`. Pour le Play Store, génère plutôt un App Bundle :

```bash
flutter build appbundle
```

## Démo web

La démo est publiée automatiquement sur GitHub Pages à chaque push sur `main` (`.github/workflows/web-demo.yml`). Pour la construire en local :

```bash
flutter build web --release --dart-define=KAIZEN_DEMO=true --no-web-resources-cdn
```

`KAIZEN_DEMO=true` ajoute les objectifs d'exemple au premier lancement. Sur le web, les objectifs sont stockés dans le navigateur, et les rappels comme le widget sont absents.

## Tests

```bash
flutter analyze
flutter test
```

Le test `test/app/app_flow_test.dart` parcourt l'application de bout en bout :
- onboarding et création d'un objectif ;
- mise à jour, check-in et suppression d'un check-in ;
- recherche dans le journal et bilan ;
- profil, langue et thème ;
- passage à l'année suivante ;
- modification, suppression et annulation de la suppression.

Il compare chaque écran à une capture de référence, rangée dans `test/app/screenshots/`.

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
      files/                Partage et sélection de fichiers (sauvegarde)
      home_screen_widget/   Widget d'écran d'accueil Android
      localization/         Textes français et anglais (flutter_localization) et formats (intl)
      notifications/        Notifications locales programmées
      preferences/          Stockage clé-valeur (shared_preferences)
      theme/                Palettes, thèmes, styles de texte et composants réutilisables
    functional/
      objectives/           Objectifs, check-ins, journal, bilan et sauvegarde
        domain/             Entités, contrats (gateways) et cas d'usage
        data/               Persistance JSON locale
        presentation/       Cubits, écrans et widgets
      profile/              Onboarding, réglages, langue et rappels
```

- **État** : `flutter_bloc` (Cubit). La chaîne d'appel est Vue, puis Cubit, puis cas d'usage, puis gateway.
- **Injection de dépendances** : `get_it`.
- **Stockage** : les objectifs dans un fichier JSON du dossier de l'application ; les réglages et le bilan dans `shared_preferences`.
- **Polices** : Bricolage Grotesque et JetBrains Mono, embarquées dans l'application.
- **Icônes** : Material Symbols Rounded, embarquées elles aussi.
