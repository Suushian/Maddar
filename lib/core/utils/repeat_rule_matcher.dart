import 'package:madaar/core/database/models.dart';
import 'package:madaar/core/utils/jalali_helper.dart';

/// الگوی تکرار عادت: daily، weekly و alternate (زوج/فرد مطلق شمسی).
abstract final class RepeatRuleMatcher {
  static bool isEligible(HabitModel habit, DateTime day) {
    final DateTime normalized = DateTime(day.year, day.month, day.day);
    final DateTime created = DateTime.parse(habit.createdAt);
    if (JalaliHelper.dateKey(normalized)
        .compareTo(JalaliHelper.dateKey(created)) < 0) {
      return false;
    }
    switch (habit.repeatType) {
      case 'daily':
        return true;
      case 'weekly':
        final int? mask = habit.weekdayMask;
        if (mask == null) {
          return false;
        }
        final int weekDay = JalaliHelper.toJalali(normalized).weekDay;
        return (mask & (1 << (weekDay - 1))) != 0;
      case 'alternate':
        return _isAlternateDay(habit, normalized);
      default:
        return false;
    }
  }

  /// پاریته براساس شماره مطلق روز محاسبه میشود تا در مرز ماهها قطع نشود.
  static bool _isAlternateDay(HabitModel habit, DateTime day) {
    final DateTime anchor = habit.repeatAnchorDate == null
        ? DateTime.parse(habit.createdAt)
        : JalaliHelper.fromDateKey(habit.repeatAnchorDate!);
    final int daySerial = _serial(day);
    final int anchorSerial = _serial(anchor);
    return (daySerial - anchorSerial).isEven;
  }

  static int _serial(DateTime date) =>
      DateTime(date.year, date.month, date.day).difference(_epoch).inDays;

  static final DateTime _epoch = DateTime(2026, 1, 1);
}
