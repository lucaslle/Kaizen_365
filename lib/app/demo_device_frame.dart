import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../layers/technical/localization/formatters.dart';

/// In the web demo shown inside an iPhone frame (`?frame=iphone`), draws the iOS status bar, the Dynamic Island
/// and the home indicator, and reserves their space like a real phone would.
class DemoDeviceFrame extends StatelessWidget {
  const DemoDeviceFrame({super.key, required this.child});

  static const _statusBarHeight = 54.0;
  static const _homeIndicatorHeight = 30.0;

  static bool get isFramed => kIsWeb && Uri.base.queryParameters['frame'] == 'iphone';

  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!isFramed) return child;
    final media = MediaQuery.of(context);
    final insets = const EdgeInsets.only(top: _statusBarHeight, bottom: _homeIndicatorHeight);
    final ink = Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black;
    return Stack(
      children: [
        MediaQuery(
          data: media.copyWith(padding: insets, viewPadding: insets),
          child: child,
        ),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: _statusBarHeight,
          child: IgnorePointer(
            child: ExcludeSemantics(
              child: Material(
                type: MaterialType.transparency,
                child: _StatusBar(ink: ink),
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 8,
          left: 0,
          right: 0,
          child: IgnorePointer(
            child: Center(
              child: Container(
                width: 134,
                height: 5,
                decoration: BoxDecoration(color: ink, borderRadius: BorderRadius.circular(3)),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _StatusBar extends StatefulWidget {
  const _StatusBar({required this.ink});

  final Color ink;

  @override
  State<_StatusBar> createState() => _StatusBarState();
}

class _StatusBarState extends State<_StatusBar> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 20), (_) => setState(() {}));
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ink = widget.ink;
    final now = DateTime.now();
    return Stack(
      children: [
        Positioned(
          top: 11,
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              width: 126,
              height: 37,
              decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(20)),
            ),
          ),
        ),
        Positioned(
          top: 0,
          bottom: 0,
          left: 0,
          right: 0,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(44, 4, 30, 0),
            child: Row(
              children: [
                Text(
                  Formatters.time(now.hour * 60 + now.minute),
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: ink, letterSpacing: -0.2),
                ),
                const Spacer(),
                Icon(Symbols.signal_cellular_alt_rounded, size: 18, color: ink, fill: 1),
                const SizedBox(width: 5),
                Icon(Symbols.wifi_rounded, size: 18, color: ink, fill: 1),
                const SizedBox(width: 6),
                _Battery(ink: ink),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _Battery extends StatelessWidget {
  const _Battery({required this.ink});

  final Color ink;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 25,
        height: 12,
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          border: Border.all(color: ink.withValues(alpha: 0.4)),
          borderRadius: BorderRadius.circular(4),
        ),
        child: FractionallySizedBox(
          alignment: Alignment.centerLeft,
          widthFactor: 0.8,
          child: DecoratedBox(
            decoration: BoxDecoration(color: ink, borderRadius: BorderRadius.circular(2)),
          ),
        ),
      ),
      const SizedBox(width: 1),
      Container(
        width: 2,
        height: 4,
        decoration: BoxDecoration(color: ink.withValues(alpha: 0.4), borderRadius: BorderRadius.circular(1)),
      ),
    ],
  );
}
