import 'key_result.dart';
import 'objective.dart';
import 'progress_change.dart';

extension CheckinRevert on Objective {
  /// The key result a change applies to: by id, or by title for changes recorded before ids were kept.
  KeyResult? keyResultOf(ProgressChange change) {
    for (final k in keyResults) {
      if (change.keyResultId.isNotEmpty ? k.id == change.keyResultId : k.title == change.subject) return k;
    }
    return null;
  }

  /// Removes a check-in and undoes its progress when the key result still holds the value it set.
  Objective withoutCheckin(String checkinId) {
    final checkin = checkins.firstWhere((c) => c.id == checkinId);
    final remaining = copyWith(
      checkins: [
        for (final c in checkins)
          if (c.id != checkinId) c,
      ],
    );
    final change = checkin.change;
    final keyResult = change == null ? null : keyResultOf(change);
    if (change == null || keyResult == null) return remaining;
    final reverted = switch (change.kind) {
      ProgressChangeKind.value ||
      ProgressChangeKind.percent when keyResult.value == change.to => keyResult.copyWith(value: change.from),
      ProgressChangeKind.milestoneDone => keyResult.copyWith(
        milestones: [for (final m in keyResult.milestones) m.title == change.subject && m.isDone ? m.toggled() : m],
      ),
      _ => null,
    };
    return reverted == null ? remaining : remaining.replacingKeyResult(reverted);
  }
}
