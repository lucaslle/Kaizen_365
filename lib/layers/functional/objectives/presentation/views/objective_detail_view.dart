import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../../technical/localization/app_locale.dart';
import '../../../../technical/theme/app_colors.dart';
import '../../../../technical/theme/app_text.dart';
import '../../../../technical/theme/widgets/app_button.dart';
import '../../domain/entities/objective.dart';
import '../../domain/entities/progress.dart';
import '../cubit/objectives_cubit.dart';
import '../cubit/objectives_state.dart';
import '../styles/domain_style.dart';
import '../widgets/checkin_timeline_item.dart';
import '../widgets/domain_label.dart';
import '../widgets/key_result_card.dart';
import '../widgets/progress_hero_card.dart';
import 'checkin_sheet.dart';
import 'key_result_update_sheet.dart';

class ObjectiveDetailView extends StatelessWidget {
  const ObjectiveDetailView({super.key, required this.objectiveId});

  final String objectiveId;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.background,
          surfaceTintColor: Colors.transparent,
          centerTitle: true,
          leading: IconButton(
            tooltip: AppLocale.back.getString(context),
            icon: const Icon(Symbols.arrow_back_rounded, color: AppColors.ink),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: BlocSelector<ObjectivesCubit, ObjectivesState, int>(
            selector: (state) => state.now.year,
            builder: (context, year) =>
                Text(context.formatString(AppLocale.detailOverline, [year]).toUpperCase(), style: AppText.overline),
          ),
        ),
        body: BlocBuilder<ObjectivesCubit, ObjectivesState>(
          builder: (context, state) {
            final objective = state.byId(objectiveId);
            if (objective == null) return const SizedBox.shrink();
            return _DetailContent(objective: objective, expected: expectedProgress(state.now));
          },
        ),
      );
}

class _DetailContent extends StatelessWidget {
  const _DetailContent({required this.objective, required this.expected});

  final Objective objective;
  final double expected;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ObjectivesCubit>();
    final keyResults = objective.keyResults;
    final doneCount = keyResults.where((k) => keyResultProgress(k) >= 1).length;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
      children: [
        DomainLabel(domain: objective.domain, tileSize: 36, fontSize: 15),
        const SizedBox(height: 10),
        Text(objective.title, style: AppText.screenTitle),
        if (objective.why.isNotEmpty) ...[
          const SizedBox(height: 10),
          Text('« ${objective.why} »', style: AppText.sans(16, height: 1.45, color: AppColors.muted).copyWith(fontStyle: FontStyle.italic)),
        ],
        const SizedBox(height: 20),
        ProgressHeroCard(objective: objective, expected: expected),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(AppLocale.keyResultsSection.getString(context), style: AppText.sectionTitle),
            Text(context.formatString(AppLocale.keyResultsDone, [doneCount, keyResults.length]),
                style: AppText.mono(13, color: AppColors.muted)),
          ],
        ),
        const SizedBox(height: 12),
        for (final keyResult in keyResults) ...[
          KeyResultCard(
            keyResult: keyResult,
            color: DomainStyle.of(objective.domain).color,
            onUpdate: () => KeyResultUpdateSheet.show(context, objective: objective, keyResult: keyResult),
            onToggleMilestone: (index) => cubit.toggleMilestone(objective, keyResult, index),
          ),
          const SizedBox(height: 12),
        ],
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(AppLocale.checkinsSection.getString(context), style: AppText.sectionTitle),
            AppButton(
              label: AppLocale.newCheckin.getString(context),
              onPressed: () => CheckinSheet.show(context, objective: objective),
              variant: AppButtonVariant.dark,
              icon: Symbols.add_rounded,
              height: 44,
              fontSize: 14,
              padding: 16,
            ),
          ],
        ),
        const SizedBox(height: 14),
        for (final checkin in objective.checkins) CheckinTimelineItem(checkin: checkin),
      ],
    );
  }
}
