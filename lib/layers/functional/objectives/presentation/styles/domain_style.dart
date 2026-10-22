import 'package:flutter/widgets.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../../technical/localization/app_locale.dart';
import '../../../../technical/theme/app_colors.dart';
import '../../domain/entities/life_domain.dart';

class DomainStyle {
  const DomainStyle(this.color, this.tint, this.icon, this.labelKey);

  final Color color;
  final Color tint;
  final IconData icon;
  final String labelKey;

  /// The domain color for text: lightened on dark themes so it keeps a readable contrast.
  Color textColor(Brightness brightness) =>
      brightness == Brightness.dark ? Color.lerp(color, const Color(0xFFFFFFFF), 0.45)! : color;

  static DomainStyle of(LifeDomain domain) => switch (domain) {
    LifeDomain.health => const DomainStyle(
      AppColors.health,
      AppColors.healthTint,
      Symbols.favorite_rounded,
      AppLocale.domainHealth,
    ),
    LifeDomain.learning => const DomainStyle(
      AppColors.learning,
      AppColors.learningTint,
      Symbols.school_rounded,
      AppLocale.domainLearning,
    ),
    LifeDomain.finances => const DomainStyle(
      AppColors.finances,
      AppColors.financesTint,
      Symbols.savings_rounded,
      AppLocale.domainFinances,
    ),
    LifeDomain.career => const DomainStyle(
      AppColors.career,
      AppColors.careerTint,
      Symbols.work_rounded,
      AppLocale.domainCareer,
    ),
    LifeDomain.relationships => const DomainStyle(
      AppColors.relationships,
      AppColors.relationshipsTint,
      Symbols.group_rounded,
      AppLocale.domainRelationships,
    ),
    LifeDomain.wellBeing => const DomainStyle(
      AppColors.wellBeing,
      AppColors.wellBeingTint,
      Symbols.spa_rounded,
      AppLocale.domainWellBeing,
    ),
  };
}
