import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../../technical/localization/app_locale.dart';
import '../../../../technical/theme/app_text.dart';
import '../../domain/entities/key_result.dart';
import '../../../../technical/theme/app_palette.dart';
import '../styles/objective_texts.dart';

class WizardKeyResultTile extends StatelessWidget {
  const WizardKeyResultTile({super.key, required this.keyResult, this.isCompact = false, this.onEdit, this.onDelete});

  final KeyResult keyResult;
  final bool isCompact;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) => Row(
    spacing: isCompact ? 10 : 12,
    children: [
      Icon(keyResultTypeIcon(keyResult.type), size: isCompact ? 20 : 22, color: context.palette.accent),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 2,
          children: [
            Text(keyResult.title, style: context.text.sans(15, weight: isCompact ? 500 : 600)),
            Text(context.keyResultDescription(keyResult), style: context.text.caption),
          ],
        ),
      ),
      if (onEdit != null)
        IconButton(
          tooltip: context.formatString(AppLocale.editItem, [keyResult.title]),
          onPressed: onEdit,
          icon: Icon(Symbols.edit_rounded, size: 20, color: context.palette.muted),
        ),
      if (onDelete != null)
        IconButton(
          tooltip: context.formatString(AppLocale.deleteItem, [keyResult.title]),
          onPressed: onDelete,
          icon: Icon(Symbols.delete_rounded, size: 20, color: context.palette.muted),
        ),
    ],
  );
}
