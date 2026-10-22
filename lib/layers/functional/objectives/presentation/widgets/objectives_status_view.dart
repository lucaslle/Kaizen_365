import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';

import '../../../../technical/localization/app_locale.dart';
import '../../../../technical/theme/app_text.dart';
import '../../../../../layers/technical/theme/app_palette.dart';
import '../cubit/objectives_state.dart';

class ObjectivesStatusView extends StatelessWidget {
  const ObjectivesStatusView({super.key, required this.status, required this.builder});

  final ObjectivesStatus status;
  final Widget Function() builder;

  @override
  Widget build(BuildContext context) => switch (status) {
    ObjectivesStatus.loading => Center(child: CircularProgressIndicator(color: context.palette.accent)),
    ObjectivesStatus.failure => Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          AppLocale.errorLoading.getString(context),
          style: context.text.bodyMuted,
          textAlign: TextAlign.center,
        ),
      ),
    ),
    ObjectivesStatus.ready => builder(),
  };
}
