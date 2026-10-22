import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';

import '../../../../technical/theme/widgets/status_pill.dart';
import '../../domain/entities/objective_status.dart';
import '../styles/status_style.dart';

class ObjectiveStatusPill extends StatelessWidget {
  const ObjectiveStatusPill({super.key, required this.status, this.height = 26});

  final ObjectiveStatus status;
  final double height;

  @override
  Widget build(BuildContext context) {
    final style = StatusStyle.of(status);
    return StatusPill(
      icon: style.icon,
      label: style.labelKey.getString(context),
      foreground: style.foreground,
      background: style.background,
      height: height,
    );
  }
}
