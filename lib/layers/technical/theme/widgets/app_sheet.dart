import 'package:flutter/material.dart';

import '../app_colors.dart';
import 'motion.dart';

Future<T?> showAppSheet<T>(BuildContext context, {required String label, required WidgetBuilder builder}) =>
    showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      barrierColor: AppColors.scrim,
      backgroundColor: AppColors.surface,
      sheetAnimationStyle: MediaQuery.disableAnimationsOf(context)
          ? AnimationStyle.noAnimation
          : const AnimationStyle(duration: Motion.sheet, curve: Motion.curve),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (context) => Semantics(
        scopesRoute: true,
        explicitChildNodes: true,
        namesRoute: true,
        label: label,
        child: Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 10, 24, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 18),
                    decoration: BoxDecoration(color: AppColors.inputBorder, borderRadius: BorderRadius.circular(2)),
                  ),
                ),
                builder(context),
              ],
            ),
          ),
        ),
      ),
    );
