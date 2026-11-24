import 'package:flutter/material.dart';
import 'package:madaar/core/theme/app_colors.dart';

/// کارت استاندارد Bento با حاشیه نورانی ظریف، شعاع ۲۴ و لمس نرم.
class BentoCard extends StatelessWidget {
  const BentoCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
    this.accent,
    this.radius = 24,
    this.height,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final Color? accent;
  final double radius;
  final double? height;

  @override
  Widget build(BuildContext context) {
    final BorderRadius borderRadius = BorderRadius.circular(radius);
    final BoxShadow? shadow = AppColors.isDark(context)
        ? null
        : const BoxShadow(
            color: Color(0x0F0F172A),
            blurRadius: 24,
            offset: Offset(0, 8),
          );

    Widget card = Container(
      height: height,
      decoration: BoxDecoration(
        color: AppColors.bgSurface(context),
        borderRadius: borderRadius,
        border: Border.all(color: AppColors.borderSubtle(context)),
        boxShadow: shadow == null ? null : <BoxShadow>[shadow],
      ),
      child: Padding(padding: padding, child: child),
    );

    if (accent != null) {
      card = Stack(
        children: <Widget>[
          card,
          Positioned(
            right: 0,
            top: 18,
            bottom: 18,
            child: Container(
              width: 3,
              decoration: BoxDecoration(
                color: accent,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        ],
      );
    }

    if (onTap == null) {
      return card;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: borderRadius,
        child: card,
      ),
    );
  }
}
