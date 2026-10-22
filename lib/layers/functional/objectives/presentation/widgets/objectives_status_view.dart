import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';

import '../../../../technical/localization/app_locale.dart';
import '../../../../technical/theme/app_colors.dart';
import '../../../../technical/theme/app_text.dart';
import '../cubit/objectives_state.dart';

class ObjectivesStatusView extends StatelessWidget {
  const ObjectivesStatusView({super.key, required this.status, required this.builder});

  final ObjectivesStatus status;
  final Widget Function() builder;

  @override
  Widget build(BuildContext context) => switch (status) {
        ObjectivesStatus.loading => const Center(child: CircularProgressIndicator(color: AppColors.accent)),
        ObjectivesStatus.failure => Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(AppLocale.errorLoading.getString(context), style: AppText.bodyMuted, textAlign: TextAlign.center),
            ),
          ),
        ObjectivesStatus.ready => builder(),
      };
}
