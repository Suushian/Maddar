import 'package:flutter/material.dart';
import 'package:madaar/core/theme/app_colors.dart';
import 'package:madaar/core/theme/app_typography.dart';

/// ساخت تمهای کامل Material 3 از توکنهای مدار.
abstract final class AppTheme {
  static final ThemeData light = _build(Brightness.light);
  static final ThemeData dark = _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final bool isDark = brightness == Brightness.dark;
    final Color background = isDark ? AppColors.bgDark : AppColors.bgLight;
    final Color surface = isDark ? AppColors.surfaceDark : Colors.white;
    final Color elevated = isDark ? AppColors.elevatedDark : Colors.white;
    final Color onSurface = isDark ? AppColors.textDark : AppColors.textLight;
    final TextTheme textTheme = AppTypography.theme(brightness);

    final ColorScheme scheme = ColorScheme.fromSeed(
      seedColor: AppColors.brandLight,
      brightness: brightness,
    ).copyWith(
      primary: isDark ? AppColors.brandDark : AppColors.brandLight,
      onPrimary: Colors.white,
      surface: surface,
      onSurface: onSurface,
      surfaceContainerHighest: elevated,
      outline: isDark
          ? const Color(0x1AFFFFFF)
          : const Color(0x0F0F172A),
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
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: onSurface),
        titleTextStyle: textTheme.titleLarge?.copyWith(color: onSurface),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: elevated.withValues(alpha: isDark ? 0.96 : 1),
        surfaceTintColor: Colors.transparent,
        showDragHandle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      visualDensity: VisualDensity.standard,
    );
  }
}
