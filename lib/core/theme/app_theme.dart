import 'package:flutter/material.dart';
import 'package:madaar/core/theme/app_colors.dart';
import 'package:madaar/core/theme/app_typography.dart';
import 'package:madaar/core/utils/motion.dart';

/// انتقال نرم صفحهها: محو + سر خوردن کوتاه وابسته به جهت RTL + کمی بزرگ شدن.
class MadaarPageTransition extends PageTransitionsBuilder {
  MadaarPageTransition();

  @override
  Duration get transitionDuration => Motion.base;

  @override
  Widget buildTransitions<T>(
    PageRoute<T>? route,
    BuildContext? context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    if (context == null || Motion.reduced(context)) {
      return child;
    }
    final bool rtl = Directionality.maybeOf(context) == TextDirection.rtl;
    final Animation<double> curved = CurvedAnimation(
      parent: animation,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );
    return FadeTransition(
      opacity: curved,
      child: SlideTransition(
        position: curved.drive(
          Tween<Offset>(
            begin: Offset(rtl ? 0.035 : -0.035, 0),
            end: Offset.zero,
          ),
        ),
        child: ScaleTransition(
          scale: curved.drive(Tween<double>(begin: 0.985, end: 1)),
          child: child,
        ),
      ),
    );
  }
}

/// ساخت تمهای کامل Material 3 از سه رنگ ثابت مدار.
abstract final class AppTheme {
  static final ThemeData light = _build(Brightness.light);
  static final ThemeData dark = _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final bool isDark = brightness == Brightness.dark;
    final Color background = isDark ? AppColors.ink : AppColors.paper;
    final Color surface =
        AppColors.stone.withValues(alpha: isDark ? 0.11 : 0.07);
    final Color elevated = isDark
        ? AppColors.stone.withValues(alpha: 0.16)
        : AppColors.paper;
    final Color onSurface = isDark ? AppColors.paper : AppColors.ink;
    final Color onFilled = isDark ? AppColors.ink : AppColors.paper;
    final TextTheme textTheme = AppTypography.theme(brightness);

    // تمام رنگهای قابل دیدن صریحاً به سه رنگ خنثی مدار بازنویسی میشوند.
    final ColorScheme scheme = ColorScheme.fromSeed(
      seedColor: AppColors.stone,
      brightness: brightness,
    ).copyWith(
      primary: AppColors.stone,
      onPrimary: onFilled,
      primaryContainer: AppColors.stone.withValues(alpha: 0.24),
      onPrimaryContainer: onSurface,
      secondary: AppColors.stone,
      onSecondary: onFilled,
      secondaryContainer: AppColors.stone.withValues(alpha: 0.16),
      onSecondaryContainer: onSurface,
      tertiary: AppColors.stone,
      onTertiary: onFilled,
      tertiaryContainer: AppColors.stone.withValues(alpha: 0.14),
      onTertiaryContainer: onSurface,
      error: AppColors.stone,
      onError: onFilled,
      errorContainer: AppColors.stone.withValues(alpha: 0.18),
      onErrorContainer: onSurface,
      surface: surface,
      onSurface: onSurface,
      surfaceTint: Colors.transparent,
      surfaceContainerLowest: background,
      surfaceContainerLow: surface,
      surfaceContainer: surface,
      surfaceContainerHigh: elevated,
      surfaceContainerHighest: elevated,
      onSurfaceVariant: AppColors.stone,
      outline: AppColors.stone.withValues(alpha: 0.38),
      outlineVariant: AppColors.stone.withValues(alpha: 0.22),
      shadow: AppColors.ink,
      scrim: AppColors.ink,
      inverseSurface: isDark ? AppColors.paper : AppColors.ink,
      onInverseSurface: isDark ? AppColors.ink : AppColors.paper,
      inversePrimary: AppColors.stone,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: background,
      fontFamily: AppTypography.fontFamily,
      textTheme: textTheme,
      dividerColor: scheme.outline,
      iconTheme: IconThemeData(color: onSurface),
      pageTransitionsTheme: PageTransitionsTheme(
        builders: <TargetPlatform, PageTransitionsBuilder>{
          TargetPlatform.android: MadaarPageTransition(),
          TargetPlatform.iOS: MadaarPageTransition(),
          TargetPlatform.fuchsia: MadaarPageTransition(),
          TargetPlatform.linux: MadaarPageTransition(),
          TargetPlatform.macOS: MadaarPageTransition(),
          TargetPlatform.windows: MadaarPageTransition(),
        },
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: onSurface),
        titleTextStyle: textTheme.titleLarge?.copyWith(color: onSurface),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: elevated,
        surfaceTintColor: Colors.transparent,
        showDragHandle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      visualDensity: VisualDensity.standard,
    );
  }
}
