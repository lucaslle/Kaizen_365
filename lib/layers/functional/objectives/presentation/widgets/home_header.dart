import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';

import '../../../../technical/localization/app_locale.dart';
import '../../../../technical/theme/app_palette.dart';
import '../../../../technical/theme/app_text.dart';
import '../../../../technical/theme/widgets/kaizen_logo.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key, required this.userName, required this.year, required this.onOpenProfile});

  final String userName;
  final int year;
  final VoidCallback onOpenProfile;

  @override
  Widget build(BuildContext context) {
    final name = userName.trim();
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 2,
            children: [
              Row(
                spacing: 8,
                children: [
                  const KaizenLogo(size: 24),
                  Text(
                    context.formatString(AppLocale.greeting, [
                      name.isEmpty ? AppLocale.greetingFallbackName.getString(context) : name,
                    ]),
                    style: context.text.bodyMuted,
                  ),
                ],
              ),
              Text(context.formatString(AppLocale.homeTitle, [year]), style: context.text.screenTitle),
            ],
          ),
        ),
        Tooltip(
          message: AppLocale.openProfile.getString(context),
          child: InkResponse(
            onTap: onOpenProfile,
            radius: 26,
            child: CircleAvatar(
              radius: 22,
              backgroundColor: context.palette.inverse,
              child: Text(
                name.isEmpty ? '?' : name.characters.first.toUpperCase(),
                style: context.text.sans(17, weight: 600, color: context.palette.onInverse),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
