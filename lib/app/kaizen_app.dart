import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:get_it/get_it.dart';

import '../layers/functional/objectives/presentation/cubit/objectives_cubit.dart';
import '../layers/functional/objectives/presentation/cubit/objectives_state.dart';
import '../layers/functional/objectives/presentation/cubit/year_review_cubit.dart';
import '../layers/functional/profile/presentation/cubit/settings_cubit.dart';
import '../layers/functional/profile/presentation/views/onboarding_view.dart';
import '../layers/technical/localization/app_language.dart';
import '../layers/technical/localization/app_locale.dart';
import '../layers/technical/theme/app_palettes.dart';
import '../layers/technical/theme/app_theme.dart';
import '../layers/technical/theme/widgets/toast.dart';
import '../layers/functional/objectives/presentation/widgets/achievement_dialog.dart';
import 'app_shell.dart';
import 'demo_device_frame.dart';
import 'home_widget_sync.dart';
import 'tab_cubit.dart';

class KaizenApp extends StatelessWidget {
  const KaizenApp({super.key});

  static final _navigatorKey = GlobalKey<NavigatorState>();

  static const _noticeKeys = {
    ObjectivesNotice.milestoneDone: AppLocale.toastMilestone,
    ObjectivesNotice.progressSaved: AppLocale.toastProgress,
    ObjectivesNotice.checkinPublished: AppLocale.toastCheckin,
    ObjectivesNotice.objectiveCreated: AppLocale.toastCreated,
    ObjectivesNotice.objectiveUpdated: AppLocale.toastUpdated,
    ObjectivesNotice.objectiveDeleted: AppLocale.toastDeleted,
    ObjectivesNotice.checkinDeleted: AppLocale.toastCheckinDeleted,
    ObjectivesNotice.saveFailed: AppLocale.errorSaving,
  };

  @override
  Widget build(BuildContext context) {
    final getIt = GetIt.instance;
    final localization = FlutterLocalization.instance;
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => SettingsCubit(getIt(), getIt(), getIt(), getIt())..refreshReminders()),
        BlocProvider(create: (_) => ObjectivesCubit(getIt(), getIt())..load()),
        BlocProvider(
          create: (_) => YearReviewCubit(getIt(), getIt(), getIt(), getIt(), getIt(), getIt(), getIt())..load(),
        ),
        BlocProvider(create: (_) => TabCubit()),
      ],
      child: BlocSelector<SettingsCubit, SettingsState, (String, String)>(
        selector: (state) => (state.settings.themeName, state.settings.languageCode),
        builder: (context, appearance) {
          final (themeName, languageCode) = appearance;
          final language = AppLanguage.resolve(languageCode);
          AppLanguage.apply(language);
          final themeChoice = AppPalettes.parse(themeName);
          return MaterialApp(
            navigatorKey: _navigatorKey,
            title: 'Kaizen 365',
            debugShowCheckedModeBanner: false,
            locale: Locale(language),
            theme: AppTheme.of(AppPalettes.of(themeChoice)),
            darkTheme: AppTheme.of(AppPalettes.night),
            themeMode: themeChoice == AppThemeName.auto ? ThemeMode.system : ThemeMode.light,
            supportedLocales: localization.supportedLocales,
            localizationsDelegates: localization.localizationsDelegates,
            builder: (context, child) => DemoDeviceFrame(
              child: ToastHost(
                child: AnnotatedRegion<SystemUiOverlayStyle>(
                  value: Theme.of(context).brightness == Brightness.dark
                      ? SystemUiOverlayStyle.light
                      : SystemUiOverlayStyle.dark,
                  child: BlocListener<ObjectivesCubit, ObjectivesState>(
                    listenWhen: (previous, current) => previous.noticeId != current.noticeId,
                    listener: (context, state) => _onNotice(context, state),
                    child: HomeWidgetSync(child: child!),
                  ),
                ),
              ),
            ),
            home: BlocBuilder<SettingsCubit, SettingsState>(
              builder: (context, state) =>
                  state.settings.hasCompletedOnboarding ? AppShell(settings: state.settings) : const OnboardingView(),
            ),
          );
        },
      ),
    );
  }

  void _onNotice(BuildContext context, ObjectivesState state) {
    final notice = state.notice!;
    if (notice == ObjectivesNotice.objectiveAchieved) {
      final navigatorContext = _navigatorKey.currentContext;
      if (navigatorContext != null) AchievementDialog.show(navigatorContext, state.noticeSubject);
      return;
    }
    showToast(
      context,
      _noticeKeys[notice]!.getString(context),
      isError: notice == ObjectivesNotice.saveFailed,
      action: notice == ObjectivesNotice.objectiveDeleted
          ? ToastAction(label: AppLocale.undo.getString(context), onPressed: context.read<ObjectivesCubit>().undoDelete)
          : null,
    );
  }
}
