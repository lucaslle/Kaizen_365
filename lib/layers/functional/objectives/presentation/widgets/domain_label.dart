import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';

import '../../../../technical/theme/app_colors.dart';
import '../../../../technical/theme/app_text.dart';
import '../../domain/entities/life_domain.dart';
import '../styles/domain_style.dart';

class DomainLabel extends StatelessWidget {
  const DomainLabel({super.key, required this.domain, this.tileSize = 32, this.fontSize = 14});

  final LifeDomain domain;
  final double tileSize;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final style = DomainStyle.of(domain);
    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: 10,
      children: [
        Container(
          width: tileSize,
          height: tileSize,
          decoration: BoxDecoration(color: style.tint, borderRadius: BorderRadius.circular(tileSize * 0.31)),
          child: Icon(style.icon, size: tileSize * 0.6, fill: 1, color: style.color),
        ),
        Text(style.labelKey.getString(context), style: AppText.sans(fontSize, weight: 500, color: AppColors.ink2)),
      ],
    );
  }
}
