import 'package:flutter/material.dart';

/// ماژولهایی که پیشتر رنگ معناگرا داشتند؛ اکنون همگی از Stone خنثی پیروی میکنند.
/// نگه داشتن enum تنها برای سازگاری API است، نه برای رنگ جداگانه.
enum MadaarAccent { tasks, habits, income, expense, journal }

/// سه رنگ ثابت و خنثی مدار؛ تمام شفافیتها از همین سه رنگ میآیند.
abstract final class AppColors {
  static const Color paper = Color(0xFFF7F6F3);
  static const Color ink = Color(0xFF202124);
  static const Color stone = Color(0xFF9B9A97);

  /// نامهای قدیمی توکنها برای سازگاری؛ همگی به Stone خنثی اشاره میکنند.
  static const Color brandLight = stone;
  static const Color brandDark = stone;
  static const Color tasks = stone;
  static const Color habits = stone;
  static const Color income = stone;
  static const Color expenseLight = stone;
  static const Color expenseDark = stone;
  static const Color journal = stone;

  static const Color bgDark = ink;
  static const Color bgLight = paper;
  static const Color surfaceDark = ink;
  static const Color elevatedDark = ink;
  static const Color textDark = paper;
  static const Color textLight = ink;

  /// طیفهای خنثی برای نمودارها، Heatmap و برچسبها — بدون رنگ جدید.
  static List<Color> get neutralTones => <Color>[
        stone,
        stone.withValues(alpha: 0.82),
        stone.withValues(alpha: 0.64),
        stone.withValues(alpha: 0.46),
        stone.withValues(alpha: 0.30),
        stone.withValues(alpha: 0.18),
      ];

  static Color tone(int index) =>
      neutralTones[index % neutralTones.length];

  static bool isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  static Color bgPrimary(BuildContext context) =>
      isDark(context) ? ink : paper;

  /// سطح کارتها: همان رنگ پسزمینه با خط مرزی نازک، بدون شیشه و سایه سنگین.
  static Color bgSurface(BuildContext context) =>
      isDark(context) ? ink : paper;

  static Color bgElevated(BuildContext context) =>
      isDark(context) ? ink : paper;

  static Color borderSubtle(BuildContext context) =>
      stone.withValues(alpha: isDark(context) ? 0.26 : 0.30);

  static Color textPrimary(BuildContext context) =>
      Theme.of(context).colorScheme.onSurface;

  static Color textSecondary(BuildContext context) => stone;

  static Color textMuted(BuildContext context) =>
      stone.withValues(alpha: 0.72);

  static Color brand(BuildContext context) => stone;

  static Color accent(BuildContext context, MadaarAccent key) => stone;
}
