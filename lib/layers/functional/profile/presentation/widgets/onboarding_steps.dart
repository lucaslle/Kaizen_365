import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';

import '../../../../technical/localization/app_locale.dart';
import '../../../../technical/theme/app_text.dart';
import '../../../../technical/theme/widgets/app_card.dart';
import '../../../../../layers/technical/theme/app_palette.dart';
import '../../../../technical/theme/widgets/kaizen_logo.dart';

class WelcomeStep extends StatelessWidget {
  const WelcomeStep({super.key});

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    spacing: 28,
    children: [
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 20,
        children: [
          const KaizenLogo(size: 132),
          Text(AppLocale.appName.getString(context), style: context.text.sans(22, weight: 700, tracking: -0.03)),
        ],
      ),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 14,
        children: [
          Text(AppLocale.heroTitle.getString(context), style: context.text.heroTitle),
          Text(context.formatString(AppLocale.heroBody, [DateTime.now().year]), style: context.text.bodyLarge),
        ],
      ),
    ],
  );
}

class HowItWorksStep extends StatelessWidget {
  const HowItWorksStep({super.key});

  @override
  Widget build(BuildContext context) {
    final steps = [
      (context.palette.inverse, context.palette.onInverse, AppLocale.stepObjectiveTitle, AppLocale.stepObjectiveBody),
      (context.palette.accent, context.palette.onAccent, AppLocale.stepKeyResultsTitle, AppLocale.stepKeyResultsBody),
      (context.palette.border, context.palette.ink, AppLocale.stepCheckinsTitle, AppLocale.stepCheckinsBody),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 28,
      children: [
        Text(AppLocale.stepsTitle.getString(context), style: context.text.onboardingTitle),
        Column(
          spacing: 12,
          children: [
            for (final (i, (background, foreground, title, body)) in steps.indexed)
              AppCard(
                radius: 20,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 16,
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: background,
                      child: Text('${i + 1}', style: context.text.mono(14, weight: 600, color: foreground)),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 4,
                        children: [
                          Text(title.getString(context), style: context.text.sans(18, weight: 600)),
                          Text(
                            body.getString(context),
                            style: context.text.sans(15, height: 1.4, color: context.palette.muted),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ],
    );
  }
}
