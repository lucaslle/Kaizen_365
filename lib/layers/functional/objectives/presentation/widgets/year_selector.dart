import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';

import '../../../../technical/localization/app_locale.dart';
import '../../../../technical/theme/app_palette.dart';
import '../../../../technical/theme/app_text.dart';
import '../../../../technical/theme/widgets/choice_tile.dart';

class YearSelector extends StatelessWidget {
  const YearSelector({super.key, required this.years, required this.selected, required this.onSelected});

  final List<int> years;
  final int selected;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) => Semantics(
    label: AppLocale.reviewYearsLabel.getString(context),
    child: SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      clipBehavior: Clip.none,
      child: Row(
        spacing: 8,
        children: [
          for (final year in years)
            ChoiceTile(
              isSelected: year == selected,
              isRadio: true,
              onTap: () => onSelected(year),
              selectedFill: context.palette.inverse,
              selectedBorder: context.palette.inverse,
              idleBorder: context.palette.inputBorder,
              radius: 22,
              height: 44,
              child: Center(
                widthFactor: 1,
                child: Text(
                  '$year',
                  style: context.text.mono(
                    14,
                    weight: 600,
                    color: year == selected ? context.palette.onInverse : context.palette.ink,
                  ),
                ),
              ),
            ),
        ],
      ),
    ),
  );
}
