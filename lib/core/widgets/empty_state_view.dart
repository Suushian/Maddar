import 'package:flutter/material.dart';
import 'package:madaar/core/theme/app_colors.dart';
import 'package:madaar/core/utils/motion.dart';

/// جایگزین اسپینر و صفحه خالی: پیام کوتاه، آیکون و یک اقدام واضح.
class EmptyStateView extends StatelessWidget {
  const EmptyStateView({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
    this.accent,
  });

  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Color? accent;

  @override
  Widget build(BuildContext context) {
    final Color color = accent ?? AppColors.brand(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Motion.entrance(
              context,
              Motion.pulse(
                context,
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 28),
                ),
                id: 'empty-icon',
              ),
              0,
              id: 'empty',
            ),
            const SizedBox(height: 16),
            Motion.entrance(
              context,
              Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              1,
              id: 'empty',
            ),
            const SizedBox(height: 8),
            Motion.entrance(
              context,
              Text(
                message,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              2,
              id: 'empty',
            ),
            if (actionLabel != null && onAction != null) ...<Widget>[
              const SizedBox(height: 20),
              Motion.entrance(
                context,
                Motion.press(
                  context,
                  FilledButton.tonal(
                    onPressed: onAction,
                    child: Text(actionLabel!),
                  ),
                ),
                3,
                id: 'empty',
              ),
            ],
          ],
        ),
      ),
    );
  }
}
