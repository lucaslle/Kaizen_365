import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../../technical/localization/app_locale.dart';
import '../../../../technical/theme/app_colors.dart';
import '../../../../technical/theme/app_text.dart';
import '../../../../technical/theme/widgets/kaizen_logo.dart';
import '../../domain/entities/progress.dart';
import '../cubit/objectives_cubit.dart';
import '../cubit/objectives_state.dart';
import '../widgets/empty_objectives_card.dart';
import '../widgets/objective_card.dart';
import '../widgets/objectives_status_view.dart';
import '../widgets/status_summary.dart';
import '../widgets/year_card.dart';
import 'objective_detail_view.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key, required this.userName, required this.onCreateObjective});

  final String userName;
  final VoidCallback onCreateObjective;

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Colors.transparent,
        floatingActionButton: FloatingActionButton.extended(
          onPressed: onCreateObjective,
          backgroundColor: AppColors.accent,
          foregroundColor: AppColors.onAccent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          icon: const Icon(Symbols.add_rounded, size: 24),
          label: Text(AppLocale.newObjectiveFab.getString(context), style: AppText.sans(16, weight: 600, color: AppColors.onAccent)),
        ),
        body: BlocBuilder<ObjectivesCubit, ObjectivesState>(
          builder: (context, state) => ObjectivesStatusView(
            status: state.status,
            builder: () => _HomeContent(state: state, userName: userName, onCreateObjective: onCreateObjective),
          ),
        ),
      );
}

class _HomeContent extends StatelessWidget {
  const _HomeContent({required this.state, required this.userName, required this.onCreateObjective});

  final ObjectivesState state;
  final String userName;
  final VoidCallback onCreateObjective;

  @override
  Widget build(BuildContext context) {
    final objectives = state.objectives;
    final expected = expectedProgress(state.now);
    final name = userName.trim();
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 112),
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 2,
                children: [
                  Row(
                    spacing: 8,
                    children: [
                      const KaizenLogo(size: 24),
                      Text(
                        context.formatString(
                            AppLocale.greeting, [name.isEmpty ? AppLocale.greetingFallbackName.getString(context) : name]),
                        style: AppText.bodyMuted,
                      ),
                    ],
                  ),
                  Text(context.formatString(AppLocale.homeTitle, [state.now.year]), style: AppText.screenTitle),
                ],
              ),
            ),
            ExcludeSemantics(
              child: CircleAvatar(
                radius: 22,
                backgroundColor: AppColors.ink,
                child: Text(name.isEmpty ? '?' : name.characters.first.toUpperCase(),
                    style: AppText.sans(17, weight: 600, color: AppColors.onAccent)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        YearCard(now: state.now, score: yearScore(objectives), expected: expected),
        const SizedBox(height: 18),
        if (objectives.isEmpty)
          EmptyObjectivesCard(onCreate: onCreateObjective)
        else ...[
          StatusSummary(objectives: objectives, expected: expected),
          const SizedBox(height: 22),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(AppLocale.objectivesSection.getString(context), style: AppText.sectionTitle),
              Text('${objectives.length}', style: AppText.mono(13, color: AppColors.muted)),
            ],
          ),
          const SizedBox(height: 18),
          for (final objective in objectives) ...[
            ObjectiveCard(
              objective: objective,
              expected: expected,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => ObjectiveDetailView(objectiveId: objective.id)),
              ),
            ),
            const SizedBox(height: 12),
          ],
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              spacing: 8,
              children: [
                Container(width: 2, height: 14, color: AppColors.ink),
                Flexible(child: Text(AppLocale.expectedLegend.getString(context), style: AppText.caption)),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
