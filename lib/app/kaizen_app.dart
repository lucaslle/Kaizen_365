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
import '../layers/technical/localization/app_locale.dart';
import '../layers/technical/theme/app_palettes.dart';
import '../layers/technical/theme/app_theme.dart';
import '../layers/technical/theme/widgets/toast.dart';
import 'app_shell.dart';
import 'tab_cubit.dart';

class KaizenApp extends StatelessWidget {
  const KaizenApp({super.key});

  static const _noticeKeys = {
    ObjectivesNotice.milestoneDone: AppLocale.toastMilestone,
    ObjectivesNotice.progressSaved: AppLocale.toastProgress,
    ObjectivesNotice.checkinPublished: AppLocale.toastCheckin,
    ObjectivesNotice.objectiveCreated: AppLocale.toastCreated,
    ObjectivesNotice.saveFailed: AppLocale.errorSaving,
  };

  @override
  Widget build(BuildContext context) {
    final getIt = GetIt.instance;
    final localization = FlutterLocalization.instance;
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => SettingsCubit(getIt(), getIt(), getIt(), getIt())..refreshReminders()),
        BlocProvider(create: (_) => ObjectivesCubit(getIt(), getIt(), getIt(), getIt(), getIt())..load()),
        BlocProvider(create: (_) => YearReviewCubit(getIt(), getIt(), getIt(), getIt())..load()),
        BlocProvider(create: (_) => TabCubit()),
      ],
      child: BlocSelector<SettingsCubit, SettingsState, String>(
        selector: (state) => state.settings.themeName,
        builder: (context, themeName) => MaterialApp(
          title: 'Kaizen 365',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.of(AppPalettes.of(AppPalettes.parse(themeName))),
          supportedLocales: localization.supportedLocales,
          localizationsDelegates: localization.localizationsDelegates,
          builder: (context, child) => AnnotatedRegion<SystemUiOverlayStyle>(
            value: Theme.of(context).brightness == Brightness.dark
                ? SystemUiOverlayStyle.light
                : SystemUiOverlayStyle.dark,
            child: BlocListener<ObjectivesCubit, ObjectivesState>(
              listenWhen: (previous, current) => previous.noticeId != current.noticeId,
              listener: (context, state) => showToast(
                context,
                _noticeKeys[state.notice]!.getString(context),
                isError: state.notice == ObjectivesNotice.saveFailed,
              ),
              child: child!,
            ),
          ),
          home: BlocBuilder<SettingsCubit, SettingsState>(
            builder: (context, state) =>
                state.settings.hasCompletedOnboarding ? AppShell(settings: state.settings) : const OnboardingView(),
          ),
        ),
      ),
    );
  }
}
