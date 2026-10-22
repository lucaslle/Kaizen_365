import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../layers/functional/objectives/presentation/views/home_view.dart';
import '../layers/functional/objectives/presentation/views/journal_view.dart';
import '../layers/functional/objectives/presentation/views/objective_wizard_view.dart';
import '../layers/functional/objectives/presentation/views/year_review_view.dart';
import '../layers/functional/onboarding/domain/entities/user_settings.dart';
import '../layers/functional/onboarding/presentation/rhythm_texts.dart';
import '../layers/technical/localization/app_locale.dart';
import '../layers/technical/theme/app_colors.dart';
import '../layers/technical/theme/app_text.dart';
import 'tab_cubit.dart';

class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.settings});

  final UserSettings settings;

  @override
  Widget build(BuildContext context) {
    void openWizard() => ObjectiveWizardView.open(context, reminderKey: rhythmReminderKey(settings.rhythm));
    final destinations = [
      (Symbols.flag_rounded, AppLocale.navObjectives),
      (Symbols.edit_note_rounded, AppLocale.navJournal),
      (Symbols.insights_rounded, AppLocale.navReview),
    ];
    return BlocBuilder<TabCubit, AppTab>(
      builder: (context, tab) => Scaffold(
        body: SafeArea(
          bottom: false,
          child: IndexedStack(
            index: tab.index,
            children: [
              HomeView(userName: settings.name, onCreateObjective: openWizard),
              const JournalView(),
              YearReviewView(onPrepareNextYear: openWizard),
            ],
          ),
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: tab.index,
          onDestinationSelected: (i) => context.read<TabCubit>().selected(AppTab.values[i]),
          backgroundColor: AppColors.navBar,
          indicatorColor: AppColors.navIndicator,
          surfaceTintColor: Colors.transparent,
          height: 80,
          labelTextStyle: WidgetStateProperty.resolveWith(
            (states) => AppText.sans(12, weight: states.contains(WidgetState.selected) ? 700 : 500),
          ),
          destinations: [
            for (final (icon, label) in destinations)
              NavigationDestination(
                icon: Icon(icon, color: AppColors.ink),
                selectedIcon: Icon(icon, fill: 1, color: AppColors.ink),
                label: label.getString(context),
              ),
          ],
        ),
      ),
    );
  }
}
