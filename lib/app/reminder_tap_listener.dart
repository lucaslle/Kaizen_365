import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import '../layers/functional/objectives/presentation/views/quick_checkin_sheet.dart';
import '../layers/functional/profile/domain/use_cases/watch_reminder_taps_use_case.dart';
import 'tab_cubit.dart';

/// Opens the check-in flow when the user taps a reminder notification.
class ReminderTapListener extends StatefulWidget {
  const ReminderTapListener({super.key, required this.child});

  final Widget child;

  @override
  State<ReminderTapListener> createState() => _ReminderTapListenerState();
}

class _ReminderTapListenerState extends State<ReminderTapListener> {
  StreamSubscription<void>? _subscription;

  @override
  void initState() {
    super.initState();
    _subscription = GetIt.I<WatchReminderTapsUseCase>()().listen((_) => _openCheckin());
  }

  void _openCheckin() {
    if (!mounted) return;
    context.read<TabCubit>().selected(AppTab.objectives);
    Navigator.of(context).popUntil((route) => route.isFirst);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) QuickCheckin.start(context);
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
