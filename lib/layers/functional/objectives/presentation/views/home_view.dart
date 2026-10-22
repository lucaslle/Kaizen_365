import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../../technical/localization/app_locale.dart';
import '../../../../technical/theme/app_text.dart';
import '../../domain/entities/progress.dart';
import '../cubit/objectives_cubit.dart';
import '../cubit/objectives_state.dart';
import '../widgets/empty_objectives_card.dart';
import '../widgets/objective_card.dart';
import '../widgets/objectives_status_view.dart';
import '../widgets/status_summary.dart';
import '../widgets/home_header.dart';
import '../widgets/sort_menu.dart';
import '../widgets/year_card.dart';
import '../../domain/entities/objective_sort.dart';
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
    final expected = expectedProgress(state.now, year: state.activeYear);
    final objectives = sortObjectives(state.objectives, state.sort, expected);
    final isManual = state.sort == ObjectiveSort.manual;
    final header = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        HomeHeader(userName: userName, year: state.activeYear, onOpenProfile: onOpenProfile),
        const SizedBox(height: 18),
        YearCard(now: state.now, year: state.activeYear, score: yearScore(objectives), expected: expected),
        const SizedBox(height: 18),
        if (objectives.isEmpty)
          EmptyObjectivesCard(onCreate: onCreateObjective)
        else ...[
          StatusSummary(objectives: objectives, expected: expected),
          const SizedBox(height: 22),
          Row(
            children: [
              Expanded(child: Text(AppLocale.objectivesSection.getString(context), style: context.text.sectionTitle)),
              Text('${objectives.length}', style: context.text.mono(13, color: context.palette.muted)),
              SortMenu(selected: state.sort),
            ],
          ),
          if (isManual && objectives.length > 1)
            Text(AppLocale.reorderHint.getString(context), style: context.text.caption),
          const SizedBox(height: 14),
        ],
      ],
    );
    return ReorderableListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 112),
      header: header,
      footer: objectives.isEmpty
          ? null
          : Padding(
              padding: const EdgeInsets.fromLTRB(4, 6, 4, 0),
              child: Row(
                spacing: 8,
                children: [
                  Container(width: 2, height: 14, color: context.palette.ink),
                  Flexible(child: Text(AppLocale.expectedLegend.getString(context), style: context.text.caption)),
                ],
              ),
            ),
      buildDefaultDragHandles: isManual,
      proxyDecorator: (child, _, _) => Material(color: Colors.transparent, child: child),
      onReorder: context.read<ObjectivesCubit>().reorder,
      children: [
        for (final objective in objectives)
          Padding(
            key: ValueKey(objective.id),
            padding: const EdgeInsets.only(bottom: 12),
            child: ObjectiveCard(
              objective: objective,
              expected: expected,
              onTap: () => Navigator.of(
                context,
              ).push(MaterialPageRoute<void>(builder: (_) => ObjectiveDetailView(objectiveId: objective.id))),
            ),
          ),
      ],
    );
  }
}
