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
import '../widgets/year_stats.dart';

class YearReviewView extends StatelessWidget {
  const YearReviewView({super.key, required this.onPrepareNextYear});

  final VoidCallback onPrepareNextYear;

  @override
  Widget build(BuildContext context) => BlocConsumer<YearReviewCubit, YearReviewState>(
    listenWhen: (previous, current) => current.hasJustClosed,
    listener: (context, state) => showToast(context, AppLocale.toastYearClosed.getString(context)),
    builder: (context, state) {
      final cubit = context.read<YearReviewCubit>();
      final now = state.now;
      final daysLeft = daysInYear(now.year) - dayOfYear(now);
      final reflections = [
        (Reflection.proud, AppLocale.reflectProud.getString(context), AppLocale.reflectProudHint),
        (Reflection.learned, AppLocale.reflectLearned.getString(context), AppLocale.reflectLearnedHint),
        (Reflection.next, context.formatString(AppLocale.reflectNext, [now.year + 1]), AppLocale.reflectNextHint),
      ];
      return ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
        children: [
          Text(context.formatString(AppLocale.reviewTitle, [now.year]), style: context.text.screenTitle),
          const SizedBox(height: 4),
          Text(context.formatString(AppLocale.reviewBody, [daysLeft]), style: context.text.bodyMuted),
          const SizedBox(height: 18),
          YearStats(objectives: state.objectives),
          if (state.objectives.isNotEmpty) ...[
            const SizedBox(height: 22),
            Text(AppLocale.perObjective.getString(context), style: context.text.sectionTitle),
            const SizedBox(height: 18),
            ObjectiveReviewList(objectives: state.objectives, carried: state.review.carriedObjectiveIds, now: now),
          ],
          const SizedBox(height: 22),
          Text(AppLocale.reflectionTitle.getString(context), style: context.text.sectionTitle),
          for (final (reflection, question, hint) in reflections) ...[
            const SizedBox(height: 18),
            Text(question, style: context.text.sans(15, weight: 500)),
            const SizedBox(height: 8),
            AppTextField(
              label: question,
              hint: hint.getString(context),
              initialValue: state.review.reflections[reflection] ?? '',
              onChanged: (text) => cubit.reflectionChanged(reflection, text),
              lines: 3,
              style: context.text.sans(15, height: 1.45),
            ),
          ],
          const SizedBox(height: 18),
          YearClosing(state: state, onPrepareNextYear: onPrepareNextYear),
        ],
      );
    },
  );
}
