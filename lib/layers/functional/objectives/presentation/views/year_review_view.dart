import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localization/flutter_localization.dart';

import '../../../../technical/localization/app_locale.dart';
import '../../../../technical/theme/app_text.dart';
import '../../../../technical/theme/widgets/app_text_field.dart';
import '../../../../technical/theme/widgets/toast.dart';
import '../../domain/entities/progress.dart';
import '../../domain/entities/year_review.dart';
import '../cubit/year_review_cubit.dart';
import '../cubit/year_review_state.dart';
import '../widgets/objective_review_list.dart';
import '../widgets/year_closing.dart';
import '../widgets/year_selector.dart';
import '../widgets/year_stats.dart';

class YearReviewView extends StatelessWidget {
  const YearReviewView({super.key, required this.onYearStarted});

  final VoidCallback onYearStarted;

  @override
  Widget build(BuildContext context) => BlocConsumer<YearReviewCubit, YearReviewState>(
    listenWhen: (previous, current) => current.hasJustClosed || current.startedYearCarriedCount != null,
    listener: (context, state) {
      final carried = state.startedYearCarriedCount;
      if (carried == null) {
        showToast(context, AppLocale.toastYearClosed.getString(context));
        return;
      }
      onYearStarted();
      showToast(context, switch (carried) {
        0 => AppLocale.yearStartedNone.getString(context),
        1 => AppLocale.yearStartedOne.getString(context),
        _ => context.formatString(AppLocale.yearStartedMany, [carried]),
      });
    },
    builder: (context, state) {
      final cubit = context.read<YearReviewCubit>();
      final now = state.now;
      final year = state.year;
      final daysLeft = daysInYear(year) - elapsedDays(year, now);
      final intro = switch (year.compareTo(now.year)) {
        < 0 => context.formatString(AppLocale.reviewOver, [year, year + 1]),
        > 0 => context.formatString(AppLocale.reviewUpcoming, [
          year,
          DateTime.utc(year).difference(DateTime.utc(now.year, now.month, now.day)).inDays,
        ]),
        _ => context.formatString(AppLocale.reviewBody, [daysLeft]),
      };
      final reflections = [
        (Reflection.proud, AppLocale.reflectProud.getString(context), AppLocale.reflectProudHint),
        (Reflection.learned, AppLocale.reflectLearned.getString(context), AppLocale.reflectLearnedHint),
        (Reflection.next, context.formatString(AppLocale.reflectNext, [year + 1]), AppLocale.reflectNextHint),
      ];
      return ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
        children: [
          if (state.availableYears.length > 1) ...[
            YearSelector(years: state.availableYears, selected: year, onSelected: cubit.yearSelected),
            const SizedBox(height: 12),
          ],
          Text(context.formatString(AppLocale.reviewTitle, [year]), style: context.text.screenTitle),
          const SizedBox(height: 4),
          Text(intro, style: context.text.bodyMuted),
          const SizedBox(height: 18),
          YearStats(objectives: state.objectives),
          if (state.objectives.isNotEmpty) ...[
            const SizedBox(height: 22),
            Text(AppLocale.perObjective.getString(context), style: context.text.sectionTitle),
            const SizedBox(height: 18),
            ObjectiveReviewList(
              objectives: state.objectives,
              carried: state.review.carriedObjectiveIds,
              now: now,
              year: year,
              isEditable: state.isActiveYear && !state.review.isClosed,
            ),
          ],
          const SizedBox(height: 22),
          Text(AppLocale.reflectionTitle.getString(context), style: context.text.sectionTitle),
          for (final (reflection, question, hint) in reflections) ...[
            const SizedBox(height: 18),
            Text(question, style: context.text.sans(15, weight: 500)),
            const SizedBox(height: 8),
            AppTextField(
              key: ValueKey('$year-${reflection.name}'),
              label: question,
              hint: hint.getString(context),
              initialValue: state.review.reflections[reflection] ?? '',
              onChanged: (text) => cubit.reflectionChanged(reflection, text),
              lines: 3,
              style: context.text.sans(15, height: 1.45),
            ),
          ],
          const SizedBox(height: 18),
          YearClosing(state: state),
        ],
      );
    },
  );
}
