import 'package:flutter/material.dart';
import 'package:madaar/core/theme/app_colors.dart';
import 'package:madaar/core/utils/motion.dart';

/// کارت مسطح به سبک Notion: حاشیه نازک، گوشه ۱۲ و بدون شیشه یا سایه سنگین.
class BentoCard extends StatelessWidget {
  const BentoCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(14),
    this.onTap,
    this.accent,
    this.radius = 12,
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
    final Widget card = Container(
      height: height,
      decoration: BoxDecoration(
        color: AppColors.bgSurface(context),
        borderRadius: borderRadius,
        border: Border.all(color: AppColors.borderSubtle(context)),
      ),
      child: Padding(padding: padding, child: child),
    );

    if (onTap == null) {
      return card;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: borderRadius,
        child: Motion.press(context, card, minScale: 0.975),
      ),
    );
  }
}
