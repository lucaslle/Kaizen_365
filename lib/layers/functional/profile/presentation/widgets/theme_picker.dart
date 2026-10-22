import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../../technical/localization/app_locale.dart';
import '../../../../technical/theme/app_palette.dart';
import '../../../../technical/theme/app_palettes.dart';
import '../../../../technical/theme/app_text.dart';

class ThemePicker extends StatelessWidget {
  const ThemePicker({super.key, required this.selected, required this.onSelected});

  final AppThemeName selected;
  final ValueChanged<AppThemeName> onSelected;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    spacing: 8,
    children: [
      Text(AppLocale.themeLabel.getString(context).toUpperCase(), style: context.text.overline),
      GridView.count(
        crossAxisCount: 3,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 0.82,
        children: [
          for (final name in AppThemeName.values)
            _ThemeTile(name: name, isSelected: name == selected, onTap: () => onSelected(name)),
        ],
      ),
    ],
  );
}

class _ThemeTile extends StatelessWidget {
  const _ThemeTile({required this.name, required this.isSelected, required this.onTap});

  final AppThemeName name;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final preview = AppPalettes.of(name);
    final current = context.palette;
    return Semantics(
      button: true,
      selected: isSelected,
      inMutuallyExclusiveGroup: true,
      label: AppPalettes.labelKey(name).getString(context),
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: isSelected ? current.accent : current.border, width: isSelected ? 2 : 1),
          ),
          child: Column(
            spacing: 6,
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: preview.background, borderRadius: BorderRadius.circular(12)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    spacing: 6,
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(color: preview.inverse, borderRadius: BorderRadius.circular(6)),
                        ),
                      ),
                      Container(
                        height: 14,
                        decoration: BoxDecoration(
                          color: preview.surface,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: preview.border),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(width: 22, height: 6, color: preview.ink),
                          CircleAvatar(
                            radius: 7,
                            backgroundColor: preview.accent,
                            child: isSelected ? Icon(Symbols.check_rounded, size: 10, color: preview.onAccent) : null,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Text(
                AppPalettes.labelKey(name).getString(context),
                style: context.text.sans(13, weight: isSelected ? 700 : 500),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
