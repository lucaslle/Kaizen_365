import 'package:flutter/widgets.dart';

abstract final class Motion {
  static const curve = Cubic(0.2, 0.8, 0.2, 1);
  static const progress = Duration(milliseconds: 500);
  static const sheet = Duration(milliseconds: 300);
  static const quick = Duration(milliseconds: 150);

  static Duration duration(BuildContext context, Duration base) =>
      MediaQuery.disableAnimationsOf(context) ? Duration.zero : base;
}
