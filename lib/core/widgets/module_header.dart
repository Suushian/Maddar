import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:madaar/core/theme/app_colors.dart';
import 'package:madaar/core/utils/motion.dart';

/// هدر مشترک صفحات ماژولها در RTL.
class ModuleHeader extends StatelessWidget {
  const ModuleHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.accent,
    this.trailing,
  });

  final String title;
  final String subtitle;
  final Color? accent;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    if (accent != null) ...<Widget>[
                      Motion.pulse(
                        context,
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: AppColors.stone.withValues(alpha: 0.75),
                            shape: BoxShape.circle,
                          ),
                        ),
                        id: 'header-dot',
                      ),
                      const SizedBox(width: 8),
                    ],
                    Flexible(
                      child: Motion.entrance(
                        context,
                        Text(
                          title,
                          style: Theme.of(context).textTheme.headlineMedium,
                          overflow: TextOverflow.ellipsis,
                        ),
                        0,
                        id: 'header',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Motion.entrance(
                  context,
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  1,
                  id: 'header',
                ),
                const SizedBox(height: 10),
                Divider(
                  height: 1,
                  color: AppColors.borderSubtle(context),
                ),
              ],
            ),
          ),
          trailing ??
              Motion.press(
                context,
                IconButton(
                  tooltip: 'تنظیمات',
                  onPressed: () => context.go('/settings'),
                  icon: const Icon(Icons.tune_rounded, size: 20),
                  color: AppColors.textSecondary(context),
                ),
              ),
        ],
      ),
    );
  }
}
