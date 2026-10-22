import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../../technical/theme/app_colors.dart';
import '../../../../technical/theme/app_text.dart';
import '../../domain/entities/checkin.dart';
import '../../domain/entities/progress_change.dart';
import '../styles/mood_style.dart';
import '../styles/objective_texts.dart';

class CheckinMood extends StatelessWidget {
  const CheckinMood({super.key, required this.checkin});

  final Checkin checkin;

  @override
  Widget build(BuildContext context) {
    final mood = checkin.mood;
    if (mood == null) return const SizedBox.shrink();
    final style = MoodStyle.of(mood);
    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: 4,
      children: [
        Icon(style.icon, size: 17, color: AppColors.muted),
        Text(style.labelKey.getString(context), style: AppText.caption),
      ],
    );
  }
}

class CheckinBody extends StatelessWidget {
  const CheckinBody({super.key, required this.checkin, required this.chipColor});

  final Checkin checkin;
  final Color chipColor;

  @override
  Widget build(BuildContext context) {
    final change = checkin.change;
    final isCreation = change?.kind == ProgressChangeKind.created;
    final text = isCreation ? context.changeText(change!) : checkin.text;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 6,
      children: [
        if (text.isNotEmpty) Text(text, style: AppText.body),
        if (change != null && !isCreation)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(color: chipColor, borderRadius: BorderRadius.circular(8)),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              spacing: 6,
              children: [
                const Icon(Symbols.trending_up_rounded, size: 16, color: AppColors.muted),
                Flexible(child: Text(context.changeText(change), style: AppText.mono(13, height: 1.4, color: AppColors.muted))),
              ],
            ),
          ),
      ],
    );
  }
}
