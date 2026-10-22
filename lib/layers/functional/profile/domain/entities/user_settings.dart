enum CheckinRhythm { weekly, biweekly, monthly }

class UserSettings {
  const UserSettings({
    this.name = '',
    this.rhythm = CheckinRhythm.weekly,
    this.themeName = '',
    this.hasCompletedOnboarding = false,
  });

  final String name;
  final CheckinRhythm rhythm;
  final String themeName;
  final bool hasCompletedOnboarding;

  UserSettings copyWith({String? name, CheckinRhythm? rhythm, String? themeName, bool? hasCompletedOnboarding}) =>
      UserSettings(
        name: name ?? this.name,
        rhythm: rhythm ?? this.rhythm,
        themeName: themeName ?? this.themeName,
        hasCompletedOnboarding: hasCompletedOnboarding ?? this.hasCompletedOnboarding,
      );
}
