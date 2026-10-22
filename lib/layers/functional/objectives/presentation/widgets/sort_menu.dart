import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../../technical/localization/app_locale.dart';
import '../../../../technical/theme/app_palette.dart';
import '../../../../technical/theme/app_text.dart';
import '../../domain/entities/objective_sort.dart';
import '../cubit/objectives_cubit.dart';

class SortMenu extends StatelessWidget {
  const SortMenu({super.key, required this.selected});

  final ObjectiveSort selected;

  static String _labelKey(ObjectiveSort sort) => switch (sort) {
    ObjectiveSort.manual => AppLocale.sortManual,
    ObjectiveSort.status => AppLocale.sortStatus,
    ObjectiveSort.progress => AppLocale.sortProgress,
  };

  @override
  Widget build(BuildContext context) => PopupMenuButton<ObjectiveSort>(
    tooltip: AppLocale.sortLabel.getString(context),
    icon: Icon(Symbols.sort_rounded, color: context.palette.ink),
    color: context.palette.surface,
    initialValue: selected,
    onSelected: context.read<ObjectivesCubit>().sortSelected,
    itemBuilder: (context) => [
      for (final sort in ObjectiveSort.values)
        CheckedPopupMenuItem(
          value: sort,
          checked: sort == selected,
          child: Text(_labelKey(sort).getString(context), style: context.text.sans(15)),
        ),
    ],
  );
}
