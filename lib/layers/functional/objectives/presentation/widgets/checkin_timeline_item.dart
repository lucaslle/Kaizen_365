import 'package:flutter/material.dart';

import '../../../../technical/localization/formatters.dart';
import '../../../../technical/theme/app_text.dart';
import '../../domain/entities/checkin.dart';
import '../styles/mood_style.dart';
import '../../../../../layers/technical/theme/app_palette.dart';
import 'checkin_content.dart';

class CheckinTimelineItem extends StatelessWidget {
  const CheckinTimelineItem({super.key, required this.checkin});

  final Checkin checkin;

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
