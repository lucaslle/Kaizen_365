import 'dart:async';

import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../app_palette.dart';
import '../app_text.dart';
import 'motion.dart';

class ToastAction {
  const ToastAction({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;
}

/// Shows a toast above everything. Without an action it lets taps through, so it never blocks the buttons it covers.
void showToast(BuildContext context, String message, {bool isError = false, ToastAction? action}) =>
    context.findAncestorStateOfType<_ToastHostState>()?.show(_ToastData(message, isError, action));

class ToastHost extends StatefulWidget {
  const ToastHost({super.key, required this.child});

  final Widget child;

  @override
  State<ToastHost> createState() => _ToastHostState();
}

class _ToastData {
  _ToastData(this.message, this.isError, this.action);

  final String message;
  final bool isError;
  final ToastAction? action;
}

class _ToastHostState extends State<ToastHost> {
  _ToastData? _current;
  Timer? _timer;

  void show(_ToastData data) {
    _timer?.cancel();
    setState(() => _current = data);
    _timer = Timer(Duration(milliseconds: data.action == null ? 2200 : 5000), _hide);
  }

  void _hide() {
    if (mounted) setState(() => _current = null);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final toast = _current;
    return Stack(
      children: [
        widget.child,
        Positioned(
          left: 24,
          right: 24,
          bottom: MediaQuery.paddingOf(context).bottom + 100,
          child: AnimatedSwitcher(
            duration: Motion.duration(context, const Duration(milliseconds: 250)),
            child: toast == null
                ? const SizedBox.shrink()
                : IgnorePointer(
                    key: ObjectKey(toast),
                    ignoring: toast.action == null,
                    child: _ToastView(toast: toast, onAction: _hide),
                  ),
          ),
        ),
      ],
    );
  }
}

class _ToastView extends StatelessWidget {
  const _ToastView({required this.toast, required this.onAction});

  final _ToastData toast;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final action = toast.action;
    return Center(
      child: Semantics(
        liveRegion: true,
        child: Material(
          color: palette.inverse,
          elevation: 6,
          shadowColor: Colors.black38,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: EdgeInsets.fromLTRB(18, action == null ? 12 : 4, action == null ? 18 : 6, action == null ? 12 : 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              spacing: 8,
              children: [
                Icon(
                  toast.isError ? Symbols.error_rounded : Symbols.check_circle_rounded,
                  size: 20,
                  color: toast.isError ? palette.accentLight : palette.toastIcon,
                ),
                Flexible(
                  child: Text(toast.message, style: context.text.sans(14, weight: 500, color: palette.onInverse)),
                ),
                if (action != null)
                  TextButton(
                    onPressed: () {
                      onAction();
                      action.onPressed();
                    },
                    child: Text(action.label, style: context.text.sans(14, weight: 700, color: palette.accentLight)),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
