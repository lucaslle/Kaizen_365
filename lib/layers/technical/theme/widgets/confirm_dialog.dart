import 'package:flutter/material.dart';

import '../app_colors.dart';
import '../app_palette.dart';
import '../app_text.dart';

/// Asks to confirm a destructive action. Resolves to true only when the user confirms.
Future<bool> confirmDestructive(
  BuildContext context, {
  required String title,
  required String body,
  required String confirmLabel,
  required String cancelLabel,
}) async {
  final palette = context.palette;
  final isConfirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      backgroundColor: palette.surface,
      title: Text(title, style: context.text.sheetTitle),
      content: Text(body, style: context.text.body),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: Text(cancelLabel, style: context.text.sans(15, weight: 600)),
        ),
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(true),
          child: Text(
            confirmLabel,
            style: context.text.sans(
              15,
              weight: 600,
              color: palette.brightness == Brightness.dark ? AppColors.lateBg : AppColors.lateFg,
            ),
          ),
        ),
      ],
    ),
  );
  return isConfirmed ?? false;
}
