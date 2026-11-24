import 'package:flutter/material.dart';

/// تایپوگرافی وزیرمتن باندلشده. تمام اعداد حالت tabular دارند تا ستونها تراز بمانند.
abstract final class AppTypography {
  static const String fontFamily = 'Vazirmatn';
  static const List<FontFeature> numericFeatures = <FontFeature>[
    FontFeature.tabularFigures(),
  ];

  static TextStyle _style({
    required double size,
    required FontWeight weight,
    required Color color,
    double height = 1.35,
  }) {
    return TextStyle(
      fontFamily: fontFamily,
      fontSize: size,
      fontWeight: weight,
      height: height,
      color: color,
      fontFeatures: numericFeatures,
    );
  }

  static TextTheme theme(Brightness brightness) {
    final Color primary = brightness == Brightness.dark
        ? const Color(0xFFF3F5F8)
        : const Color(0xFF11151C);
    final Color secondary = brightness == Brightness.dark
        ? const Color(0xFF949EAE)
        : const Color(0xFF525C6B);

    return TextTheme(
      displayLarge: _style(
        size: 28,
        weight: FontWeight.w800,
        color: primary,
        height: 1.2,
      ),
      headlineMedium: _style(
        size: 22,
        weight: FontWeight.w700,
        color: primary,
        height: 1.25,
      ),
      titleLarge: _style(
        size: 18,
        weight: FontWeight.w700,
        color: primary,
      ),
      titleMedium: _style(
        size: 16,
        weight: FontWeight.w500,
        color: primary,
      ),
      bodyLarge: _style(size: 16, weight: FontWeight.w400, color: primary),
      bodyMedium: _style(size: 15, weight: FontWeight.w400, color: primary),
      bodySmall: _style(size: 13, weight: FontWeight.w400, color: secondary),
      labelLarge: _style(size: 14, weight: FontWeight.w500, color: primary),
      labelMedium: _style(size: 12, weight: FontWeight.w500, color: secondary),
      labelSmall: _style(size: 11, weight: FontWeight.w500, color: secondary),
    );
  }
}
