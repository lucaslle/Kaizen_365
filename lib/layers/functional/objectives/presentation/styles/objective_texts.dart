import 'package:flutter/widgets.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../../technical/localization/app_locale.dart';
import '../../../../technical/localization/formatters.dart';
import '../../domain/entities/key_result.dart';
import '../../domain/entities/progress_change.dart';

extension ObjectiveTexts on BuildContext {
  String keyResultCount(int count) =>
      formatString(count > 1 ? AppLocale.keyResultCountMany : AppLocale.keyResultCountOne, [count]);

  String typeLabel(KeyResultType type) => switch (type) {
        KeyResultType.numeric => AppLocale.typeNumeric,
        KeyResultType.percent => AppLocale.typePercent,
        KeyResultType.milestones => AppLocale.typeMilestones,
      }
          .getString(this);

  String keyResultValue(KeyResult k) => switch (k.type) {
        KeyResultType.numeric =>
          formatString(AppLocale.valueNumeric, [Formatters.number(k.value), Formatters.number(k.target), k.unit]).trim(),
        KeyResultType.percent => formatString(AppLocale.valuePercent, [Formatters.number(k.value)]),
        KeyResultType.milestones => formatString(AppLocale.valueMilestones, [k.doneCount, k.milestones.length]),
      };

  String keyResultDescription(KeyResult k) => switch (k.type) {
        KeyResultType.numeric =>
          formatString(AppLocale.keyResultDescNumeric, [Formatters.number(k.start), Formatters.number(k.target), k.unit]).trim(),
        KeyResultType.percent => AppLocale.keyResultDescPercent.getString(this),
        KeyResultType.milestones => formatString(
            k.milestones.length > 1 ? AppLocale.keyResultDescMilestonesMany : AppLocale.keyResultDescMilestonesOne,
            [k.milestones.length],
          ),
      };

  String changeText(ProgressChange c) => switch (c.kind) {
        ProgressChangeKind.created => AppLocale.changeCreated.getString(this),
        ProgressChangeKind.value => formatString(
            AppLocale.changeValue, [c.subject, Formatters.number(c.from), Formatters.number(c.to), c.unit]).trim(),
        ProgressChangeKind.percent =>
          formatString(AppLocale.changePercent, [c.subject, Formatters.number(c.from), Formatters.number(c.to)]),
        ProgressChangeKind.milestones =>
          formatString(AppLocale.changeMilestones, [c.subject, c.from.round(), c.to.round(), c.total]),
        ProgressChangeKind.milestoneDone => formatString(AppLocale.changeMilestoneDone, [c.subject]),
      };
}

IconData keyResultTypeIcon(KeyResultType type) => switch (type) {
      KeyResultType.numeric => Symbols.tag_rounded,
      KeyResultType.percent => Symbols.percent_rounded,
      KeyResultType.milestones => Symbols.checklist_rounded,
    };
