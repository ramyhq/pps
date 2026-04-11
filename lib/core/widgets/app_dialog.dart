import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

class AppDialog extends StatelessWidget {
  const AppDialog({
    super.key,
    required this.title,
    required this.content,
    required this.actions,
    this.maxWidth = 520,
    this.barrierDismissible = true,
  });

  final Widget title;
  final Widget content;
  final List<Widget> actions;
  final double maxWidth;
  final bool barrierDismissible;

  static Future<T?> show<T>({
    required BuildContext context,
    required Widget title,
    required Widget content,
    required List<Widget> actions,
    double maxWidth = 520,
    bool barrierDismissible = true,
  }) {
    return showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (_) => AppDialog(
        title: title,
        content: content,
        actions: actions,
        maxWidth: maxWidth,
        barrierDismissible: barrierDismissible,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final effectiveWidth = constraints.maxWidth < maxWidth
            ? constraints.maxWidth
            : maxWidth;
        return AlertDialog(
          backgroundColor: AppColors.white,
          surfaceTintColor: AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.r12),
            side: const BorderSide(color: AppColors.border),
          ),
          title: title,
          content: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: effectiveWidth),
            child: SizedBox(width: effectiveWidth, child: content),
          ),
          actions: actions,
        );
      },
    );
  }
}
