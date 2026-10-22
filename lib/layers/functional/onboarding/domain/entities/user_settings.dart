enum CheckinRhythm { weekly, biweekly, monthly }

class UserSettings {
  const UserSettings({this.name = '', this.rhythm = CheckinRhythm.weekly, this.hasCompletedOnboarding = false});

  final String name;
  final CheckinRhythm rhythm;
  final bool hasCompletedOnboarding;

  UserSettings copyWith({String? name, CheckinRhythm? rhythm, bool? hasCompletedOnboarding}) => UserSettings(
        name: name ?? this.name,
        rhythm: rhythm ?? this.rhythm,
        hasCompletedOnboarding: hasCompletedOnboarding ?? this.hasCompletedOnboarding,
      );
}
