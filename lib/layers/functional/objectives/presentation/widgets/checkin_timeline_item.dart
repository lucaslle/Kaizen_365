import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../../technical/localization/app_locale.dart';

import '../../../../technical/localization/formatters.dart';
import '../../../../technical/theme/app_text.dart';
import '../../domain/entities/checkin.dart';
import '../styles/mood_style.dart';
import '../../../../technical/theme/app_palette.dart';
import 'checkin_content.dart';

class CheckinTimelineItem extends StatelessWidget {
  const CheckinTimelineItem({super.key, required this.checkin, this.onDelete});

  final Checkin checkin;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final mood = checkin.mood;
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 12,
        children: [
          SizedBox(
            width: 20,
            child: Column(
              children: [
                const SizedBox(height: 6),
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: mood == null ? context.palette.dot : MoodStyle.of(mood).color,
                  ),
                ),
                const SizedBox(height: 4),
                Expanded(child: Container(width: 2, color: context.palette.border)),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 6,
                children: [
                  Row(
                    spacing: 10,
                    children: [
                      Text(Formatters.shortDate(checkin.date), style: context.text.monoSmall),
                      CheckinMood(checkin: checkin),
                      if (onDelete != null) ...[
                        const Spacer(),
                        IconButton(
                          tooltip: AppLocale.deleteCheckin.getString(context),
                          onPressed: onDelete,
                          visualDensity: VisualDensity.compact,
                          icon: Icon(Symbols.delete_rounded, size: 18, color: context.palette.muted),
                        ),
                      ],
                    ],
                  ),
                  CheckinBody(checkin: checkin, chipColor: context.palette.sunken),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
