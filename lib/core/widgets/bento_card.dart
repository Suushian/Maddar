import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:madaar/core/theme/app_colors.dart';
import 'package:madaar/core/utils/motion.dart';

/// کارت Bento شیشهای با شعاع ۲۸، حاشیه Stone و سایه نرم Ink.
class BentoCard extends StatelessWidget {
  const BentoCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
    this.accent,
    this.radius = 28,
    this.height,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;

  /// نگه داشتهشده برای سازگاری؛ رنگهای جداگانه ماژولها حذف شدند.
  final Color? accent;
  final double radius;
  final double? height;

  @override
  Widget build(BuildContext context) {
    final BorderRadius borderRadius = BorderRadius.circular(radius);
    final List<BoxShadow>? shadows = AppColors.isDark(context)
        ? null
        : <BoxShadow>[
            BoxShadow(
              color: AppColors.ink.withValues(alpha: 0.06),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ];

    Widget card = Container(
      height: height,
      decoration: BoxDecoration(
        color: AppColors.bgSurface(context),
        borderRadius: borderRadius,
        border: Border.all(color: AppColors.borderSubtle(context)),
        boxShadow: shadows,
      ),
      child: ClipRRect(
        borderRadius: borderRadius,
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Padding(padding: padding, child: child),
        ),
      ),
    );

    if (onTap == null) {
      return card;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: borderRadius,
        child: Motion.spring(context, card),
      ),
    );
  }
}
