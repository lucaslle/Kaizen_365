import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../../technical/localization/app_locale.dart';
import '../../../../technical/theme/app_text.dart';
import '../../../../technical/theme/widgets/app_text_field.dart';
import '../../../../technical/theme/widgets/choice_tile.dart';
import '../cubit/journal_filter_cubit.dart';
import '../cubit/objectives_cubit.dart';
import '../cubit/objectives_state.dart';
import '../widgets/journal_entry.dart';
import '../../../../technical/theme/app_palette.dart';
import '../widgets/objectives_status_view.dart';

class JournalView extends StatelessWidget {
  const JournalView({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => JournalFilterCubit(),
    child: BlocBuilder<ObjectivesCubit, ObjectivesState>(
      builder: (context, state) => ObjectivesStatusView(
        status: state.status,
        builder: () => BlocBuilder<JournalFilterCubit, JournalFilter>(
          builder: (context, filter) => _JournalContent(
            state: state,
            filter: state.byId(filter.objectiveId ?? '') == null
                ? JournalFilter(query: filter.query, queryRevision: filter.queryRevision)
                : filter,
          ),
        ),
      ),
    ),
  );
}

class _JournalContent extends StatelessWidget {
  const _JournalContent({required this.state, required this.filter});

  final ObjectivesState state;
  final JournalFilter filter;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<JournalFilterCubit>();
    final entries = [
      for (final o in state.objectives)
        for (final c in o.checkins)
          if (filter.matches(c, o)) (checkin: c, objective: o),
    ]..sort((a, b) => b.checkin.date.compareTo(a.checkin.date));
    final filters = [
      (id: null, label: AppLocale.filterAll.getString(context)),
      for (final o in state.objectives) (id: o.id, label: o.title),
    ];
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
      children: [
        Text(AppLocale.journalTitle.getString(context), style: context.text.screenTitle),
        const SizedBox(height: 4),
        Text(AppLocale.journalBody.getString(context), style: context.text.bodyMuted),
        const SizedBox(height: 16),
        Row(
          spacing: 4,
          children: [
            Expanded(
              child: AppTextField(
                key: ValueKey(filter.queryRevision),
                label: AppLocale.journalSearch.getString(context),
                hint: AppLocale.journalSearch.getString(context),
                initialValue: filter.query,
                onChanged: cubit.queryChanged,
                radius: 22,
                verticalPadding: 12,
                style: context.text.sans(15),
              ),
            ),
            if (filter.query.isNotEmpty)
              IconButton(
                tooltip: AppLocale.clearSearch.getString(context),
                onPressed: cubit.queryCleared,
                icon: Icon(Symbols.close_rounded, color: context.palette.muted),
              ),
          ],
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          clipBehavior: Clip.none,
          child: Row(
            spacing: 8,
            children: [
              for (final f in filters)
                ChoiceTile(
                  isSelected: filter.objectiveId == f.id,
                  onTap: () => cubit.objectiveSelected(f.id),
                  selectedFill: context.palette.inverse,
                  selectedBorder: context.palette.inverse,
                  idleBorder: context.palette.inputBorder,
                  radius: 22,
                  height: 44,
                  child: Center(
                    widthFactor: 1,
                    child: Text(
                      f.label,
                      style: context.text.sans(
                        14,
                        weight: 500,
                        color: filter.objectiveId == f.id ? context.palette.onInverse : context.palette.ink,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        if (entries.isEmpty)
          Text(
            (filter.query.trim().isEmpty ? AppLocale.journalEmpty : AppLocale.journalNoResult).getString(context),
            style: context.text.bodyMuted,
          ),
        for (final e in entries) JournalEntry(checkin: e.checkin, objective: e.objective),
      ],
    );
  }
}
