import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localization/flutter_localization.dart';

import '../../../../technical/localization/app_locale.dart';
import '../../../../technical/theme/app_colors.dart';
import '../../../../technical/theme/app_text.dart';
import '../../../../technical/theme/widgets/app_button.dart';
import '../../../../technical/theme/widgets/app_card.dart';
import '../../domain/entities/progress.dart';
import '../cubit/year_review_cubit.dart';
import '../cubit/year_review_state.dart';

class YearClosing extends StatelessWidget {
  const YearClosing({super.key, required this.state, required this.onPrepareNextYear});

  final YearReviewState state;
  final VoidCallback onPrepareNextYear;

  @override
  Widget build(BuildContext context) {
    final year = state.now.year;
    if (!state.review.isClosed) {
      return AppButton(
        label: context.formatString(AppLocale.closeYear, [year]),
        onPressed: context.read<YearReviewCubit>().closeYear,
        variant: AppButtonVariant.dark,
      );
    }
    final carried = state.objectives
        .where((o) => objectiveProgress(o) < 0.999 && state.review.carriedObjectiveIds.contains(o.id))
        .length;
    final carriedText = switch (carried) {
      0 => context.formatString(AppLocale.carriedNone, [year + 1]),
      1 => context.formatString(AppLocale.carriedOne, [year + 1]),
      _ => context.formatString(AppLocale.carriedMany, [carried, year + 1]),
    };
    return AppCard(
      color: AppColors.ink,
      borderColor: null,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 12,
        children: [
          Text(context.formatString(AppLocale.yearClosed, [year]),
              style: AppText.sans(22, weight: 600, tracking: -0.02, color: AppColors.onAccent)),
          Text(carriedText, style: AppText.sans(15, height: 1.45, color: AppColors.darkCardText)),
          AppButton(
            label: context.formatString(AppLocale.prepareNext, [year + 1]),
            onPressed: onPrepareNextYear,
            variant: AppButtonVariant.light,
            height: 46,
            fontSize: 15,
            padding: 18,
          ),
        ],
      ),
    );
  }
}
