import '../../../technical/localization/app_locale.dart';
import '../domain/entities/user_settings.dart';

String rhythmLabelKey(CheckinRhythm rhythm) => switch (rhythm) {
      CheckinRhythm.weekly => AppLocale.rhythmWeekly,
      CheckinRhythm.biweekly => AppLocale.rhythmBiweekly,
      CheckinRhythm.monthly => AppLocale.rhythmMonthly,
    };

String rhythmReminderKey(CheckinRhythm rhythm) => switch (rhythm) {
      CheckinRhythm.weekly => AppLocale.reminderWeekly,
      CheckinRhythm.biweekly => AppLocale.reminderBiweekly,
      CheckinRhythm.monthly => AppLocale.reminderMonthly,
    };
