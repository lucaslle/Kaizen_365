import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../app_colors.dart';

void showToast(ScaffoldMessengerState messenger, String message, {bool isError = false}) => messenger
  ..hideCurrentSnackBar()
  ..showSnackBar(
    SnackBar(
      duration: const Duration(milliseconds: 2200),
      margin: const EdgeInsets.fromLTRB(40, 0, 40, 96),
      content: Semantics(
        liveRegion: true,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(isError ? Symbols.error_rounded : Symbols.check_circle_rounded,
                size: 20, color: isError ? AppColors.accentLight : AppColors.toastIcon),
            const SizedBox(width: 8),
            Flexible(child: Text(message)),
          ],
        ),
      ),
    ),
  );
