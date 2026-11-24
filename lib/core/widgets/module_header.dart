import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:madaar/core/theme/app_colors.dart';

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
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    if (accent != null) ...<Widget>[
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: accent,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    Flexible(
                      child: Text(
                        title,
                        style: Theme.of(context).textTheme.headlineMedium,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          trailing ?? IconButton(
            tooltip: 'تنظیمات',
            onPressed: () => context.go('/settings'),
            icon: const Icon(Icons.tune_rounded),
            color: AppColors.textSecondary(context),
          ),
        ],
      ),
    );
  }
}
