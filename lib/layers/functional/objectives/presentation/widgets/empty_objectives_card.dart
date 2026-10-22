import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';

import '../../../../technical/localization/app_locale.dart';
import '../../../../technical/theme/app_colors.dart';
import '../../../../technical/theme/app_text.dart';
import '../../../../technical/theme/widgets/app_button.dart';
import '../../../../technical/theme/widgets/app_card.dart';

class EmptyObjectivesCard extends StatelessWidget {
  const EmptyObjectivesCard({super.key, required this.onCreate});

  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) => AppCard(
        radius: 24,
        padding: const EdgeInsets.all(24),
        borderColor: AppColors.inputBorder,
        isDashed: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 14,
          children: [
            Text(AppLocale.emptyTitle.getString(context), style: AppText.sans(22, weight: 600, tracking: -0.02)),
            Text(AppLocale.emptyBody.getString(context), style: AppText.bodyMuted),
            AppButton(
              label: AppLocale.emptyCta.getString(context),
              onPressed: onCreate,
              height: 48,
              fontSize: 15,
              padding: 20,
            ),
          ],
        ),
      );
}
