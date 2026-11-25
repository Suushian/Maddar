import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// انیمیشنهای ورودی کوتاه و staggered با احترام به تنظیم reduced motion.
abstract final class Motion {
  static const Duration step = Duration(milliseconds: 70);
  static const Duration duration = Duration(milliseconds: 320);

  static bool reduced(BuildContext context) =>
      MediaQuery.disableAnimationsOf(context);

  static Widget entrance(BuildContext context, Widget child, int index) {
    if (reduced(context)) {
      return child;
    }
    final Duration delay = Duration(milliseconds: step.inMilliseconds * index);
    return child
        .animate()
        .fadeIn(delay: delay, duration: duration, curve: Curves.easeOut)
        .slideY(
          begin: 0.035,
          end: 0,
          delay: delay,
          duration: duration,
          curve: Curves.easeOutCubic,
        );
  }

  /// پاسخ لمسی نرم شبیه Spring، بدون حرکت در حالت reduced motion.
  static Widget spring(BuildContext context, Widget child) {
    if (reduced(context)) {
      return child;
    }
    return child
        .animate()
        .scale(
          begin: const Offset(0.96, 0.96),
          end: const Offset(1, 1),
          duration: const Duration(milliseconds: 380),
          curve: Curves.elasticOut,
        );
  }
}
