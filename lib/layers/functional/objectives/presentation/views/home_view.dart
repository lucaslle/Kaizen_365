import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../../technical/localization/app_locale.dart';
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
import '../../../../technical/theme/app_palette.dart';
import 'objective_detail_view.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key, required this.userName, required this.onCreateObjective, required this.onOpenProfile});

  final String userName;
  final VoidCallback onCreateObjective;
  final VoidCallback onOpenProfile;

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.transparent,
    floatingActionButton: FloatingActionButton.extended(
      onPressed: onCreateObjective,
      backgroundColor: context.palette.accent,
      foregroundColor: context.palette.onAccent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      icon: const Icon(Symbols.add_rounded, size: 24),
      label: Text(
        AppLocale.newObjectiveFab.getString(context),
        style: context.text.sans(16, weight: 600, color: context.palette.onAccent),
      ),
    ),
    body: BlocBuilder<ObjectivesCubit, ObjectivesState>(
      builder: (context, state) => ObjectivesStatusView(
        status: state.status,
        builder: () => _HomeContent(
          state: state,
          userName: userName,
          onCreateObjective: onCreateObjective,
          onOpenProfile: onOpenProfile,
        ),
      ),
    ),
  );
}

class _HomeContent extends StatelessWidget {
  const _HomeContent({
    required this.state,
    required this.userName,
    required this.onCreateObjective,
    required this.onOpenProfile,
  });

  final ObjectivesState state;
  final String userName;
  final VoidCallback onCreateObjective;
  final VoidCallback onOpenProfile;

  @override
  Widget build(BuildContext context) {
    final objectives = state.objectives;
    final expected = expectedProgress(state.now, year: state.activeYear);
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
                        context.formatString(AppLocale.greeting, [
                          name.isEmpty ? AppLocale.greetingFallbackName.getString(context) : name,
                        ]),
                        style: context.text.bodyMuted,
                      ),
                    ],
                  ),
                  Text(context.formatString(AppLocale.homeTitle, [state.activeYear]), style: context.text.screenTitle),
                ],
              ),
            ),
            Tooltip(
              message: AppLocale.openProfile.getString(context),
              child: InkResponse(
                onTap: onOpenProfile,
                radius: 26,
                child: CircleAvatar(
                  radius: 22,
                  backgroundColor: context.palette.inverse,
                  child: Text(
                    name.isEmpty ? '?' : name.characters.first.toUpperCase(),
                    style: context.text.sans(17, weight: 600, color: context.palette.onInverse),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        YearCard(now: state.now, year: state.activeYear, score: yearScore(objectives), expected: expected),
        const SizedBox(height: 18),
        if (objectives.isEmpty)
          EmptyObjectivesCard(onCreate: onCreateObjective)
        else ...[
          StatusSummary(objectives: objectives, expected: expected),
          const SizedBox(height: 22),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(AppLocale.objectivesSection.getString(context), style: context.text.sectionTitle),
              Text('${objectives.length}', style: context.text.mono(13, color: context.palette.muted)),
            ],
          ),
          const SizedBox(height: 18),
          for (final objective in objectives) ...[
            ObjectiveCard(
              objective: objective,
              expected: expected,
              onTap: () => Navigator.of(
                context,
              ).push(MaterialPageRoute<void>(builder: (_) => ObjectiveDetailView(objectiveId: objective.id))),
            ),
            const SizedBox(height: 12),
          ],
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              spacing: 8,
              children: [
                Container(width: 2, height: 14, color: context.palette.ink),
                Flexible(child: Text(AppLocale.expectedLegend.getString(context), style: context.text.caption)),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
