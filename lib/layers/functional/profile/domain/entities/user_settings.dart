enum CheckinRhythm { weekly, biweekly, monthly }

class UserSettings {
  const UserSettings({
    this.name = '',
    this.rhythm = CheckinRhythm.weekly,
    this.themeName = '',
    this.languageCode = '',
    this.reminderMinutes = defaultReminderMinutes,
    this.areRemindersEnabled = true,
    this.hasCompletedOnboarding = false,
  });

  static const defaultReminderMinutes = 18 * 60;

  final String name;
  final CheckinRhythm rhythm;
  final String themeName;

  /// Empty means "follow the phone language".
  final String languageCode;

  /// Time of day of the check-in reminder, in minutes after midnight.
  final int reminderMinutes;
  final bool areRemindersEnabled;
  final bool hasCompletedOnboarding;

  bool remindsDifferentlyFrom(UserSettings other) =>
      rhythm != other.rhythm ||
      reminderMinutes != other.reminderMinutes ||
      areRemindersEnabled != other.areRemindersEnabled ||
      languageCode != other.languageCode;

  UserSettings copyWith({
    String? name,
    CheckinRhythm? rhythm,
    String? themeName,
    String? languageCode,
    int? reminderMinutes,
    bool? areRemindersEnabled,
    bool? hasCompletedOnboarding,
  }) => UserSettings(
    name: name ?? this.name,
    rhythm: rhythm ?? this.rhythm,
    themeName: themeName ?? this.themeName,
    languageCode: languageCode ?? this.languageCode,
    reminderMinutes: reminderMinutes ?? this.reminderMinutes,
    areRemindersEnabled: areRemindersEnabled ?? this.areRemindersEnabled,
    hasCompletedOnboarding: hasCompletedOnboarding ?? this.hasCompletedOnboarding,
  );
}
