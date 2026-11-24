import 'package:flutter/material.dart';

/// ماژولهایی که رنگ معناگرا دارند.
enum MadaarAccent { tasks, habits, income, expense, journal }

/// توکنهای رنگی دو تم مدار. مقادیر از docs/03-DESIGN_SYSTEM.md میآیند.
abstract final class AppColors {
  static const Color brandLight = Color(0xFF6366F1);
  static const Color brandDark = Color(0xFF818CF8);

  static const Color tasks = Color(0xFF38BDF8);
  static const Color habits = Color(0xFF10B981);
  static const Color income = Color(0xFF22C55E);
  static const Color expenseLight = Color(0xFFF59E0B);
  static const Color expenseDark = Color(0xFFFB7185);
  static const Color journal = Color(0xFFC084FC);

  static const Color bgDark = Color(0xFF090B0E);
  static const Color surfaceDark = Color(0xFF12151B);
  static const Color elevatedDark = Color(0xFF1A1F28);
  static const Color bgLight = Color(0xFFF6F5F1);
  static const Color textDark = Color(0xFFF3F5F8);
  static const Color textLight = Color(0xFF11151C);
  static const Color secondaryDark = Color(0xFF949EAE);
  static const Color secondaryLight = Color(0xFF525C6B);
  static const Color mutedDark = Color(0xFF5B6472);
  static const Color mutedLight = Color(0xFF8E98A8);

  static bool isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  static Color bgPrimary(BuildContext context) =>
      isDark(context) ? bgDark : bgLight;

  static Color bgSurface(BuildContext context) =>
      isDark(context) ? surfaceDark : Colors.white;

  static Color bgElevated(BuildContext context) =>
      isDark(context) ? elevatedDark : Colors.white;

  static Color borderSubtle(BuildContext context) => isDark(context)
      ? Colors.white.withValues(alpha: 0.07)
      : const Color(0xFF0F172A).withValues(alpha: 0.06);

  static Color textPrimary(BuildContext context) =>
      Theme.of(context).colorScheme.onSurface;

  static Color textSecondary(BuildContext context) =>
      isDark(context) ? secondaryDark : secondaryLight;

  static Color textMuted(BuildContext context) =>
      isDark(context) ? mutedDark : mutedLight;

  static Color brand(BuildContext context) =>
      isDark(context) ? brandDark : brandLight;

  static Color accent(BuildContext context, MadaarAccent key) {
    switch (key) {
      case MadaarAccent.tasks:
        return tasks;
      case MadaarAccent.habits:
        return habits;
      case MadaarAccent.income:
        return income;
      case MadaarAccent.expense:
        return isDark(context) ? expenseDark : expenseLight;
      case MadaarAccent.journal:
        return journal;
    }
  }
}
