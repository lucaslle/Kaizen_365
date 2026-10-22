import 'package:flutter/material.dart';

import '../../../../technical/localization/formatters.dart';
import '../../../../technical/theme/app_text.dart';
import '../../../../technical/theme/widgets/app_card.dart';
import '../../domain/entities/checkin.dart';
import '../../domain/entities/objective.dart';
import '../styles/domain_style.dart';
import '../../../../technical/theme/app_palette.dart';
import 'checkin_content.dart';

class JournalEntry extends StatelessWidget {
  const JournalEntry({super.key, required this.checkin, required this.objective});

  final Checkin checkin;
  final Objective objective;

  @override
  Widget build(BuildContext context) => IntrinsicHeight(
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 12,
      children: [
        SizedBox(
          width: 56,
          child: Column(
            spacing: 6,
            children: [
              const SizedBox(height: 0),
              Text(Formatters.shortDate(checkin.date), style: context.text.monoSmall, maxLines: 1),
              Expanded(child: Container(width: 2, color: context.palette.border)),
            ],
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: AppCard(
              radius: 18,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 8,
                children: [
                  Row(
                    spacing: 8,
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: DomainStyle.of(objective.domain).color,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                      Expanded(child: Text(objective.title, style: context.text.sans(14, weight: 600))),
                    ],
                  ),
                  CheckinMood(checkin: checkin),
                  CheckinBody(checkin: checkin, chipColor: context.palette.background),
                ],
              ),
            ),
          ),
        ),
      ],
    ),
  );
}
