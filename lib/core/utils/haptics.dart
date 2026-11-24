import 'package:flutter/services.dart';

/// ویبرههای بسیار کوتاه و بدون مزاحمت؛ فقط در نقاط لمسی معنیدار فراخوانی میشوند.
abstract final class Haptics {
  static Future<void> tap() => HapticFeedback.lightImpact();

  static Future<void> toggle() => HapticFeedback.selectionClick();

  static Future<void> success() => HapticFeedback.mediumImpact();

  static Future<void> warning() => HapticFeedback.heavyImpact();
}
