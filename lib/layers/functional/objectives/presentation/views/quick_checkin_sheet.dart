import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../../technical/localization/app_locale.dart';
import '../../../../technical/theme/app_palette.dart';
import '../../../../technical/theme/app_text.dart';
import '../../../../technical/theme/widgets/app_sheet.dart';
import '../../domain/entities/objective.dart';
import '../cubit/objectives_cubit.dart';
import '../widgets/domain_label.dart';
import 'checkin_sheet.dart';

/// Opened from a reminder: pick the objective to check in on.
abstract final class QuickCheckin {
  static Future<void> start(BuildContext context) async {
    final objectives = context.read<ObjectivesCubit>().state.objectives;
    if (objectives.isEmpty) return;
    if (objectives.length == 1) return CheckinSheet.show(context, objective: objectives.single);
    final picked = await showAppSheet<Objective>(
      context,
      label: AppLocale.quickCheckinTitle.getString(context),
      builder: (sheetContext) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 8,
        children: [
          Text(AppLocale.quickCheckinTitle.getString(context), style: sheetContext.text.sheetTitle),
          const SizedBox(height: 4),
          for (final objective in objectives)
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 4),
              title: Text(objective.title, style: sheetContext.text.sans(16, weight: 600)),
              subtitle: Align(
                alignment: Alignment.centerLeft,
                child: DomainLabel(domain: objective.domain, tileSize: 24),
              ),
              trailing: Icon(Symbols.chevron_right_rounded, color: sheetContext.palette.muted),
              onTap: () => Navigator.of(sheetContext).pop(objective),
            ),
        ],
      ),
    );
    if (picked != null && context.mounted) await CheckinSheet.show(context, objective: picked);
  }
}
