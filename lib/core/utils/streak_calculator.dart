import 'package:madaar/core/database/models.dart';
import 'package:madaar/core/utils/jalali_helper.dart';
import 'package:madaar/core/utils/repeat_rule_matcher.dart';
import 'package:shamsi_date/shamsi_date.dart';

/// محاسبه خالص زنجیرهها و نرخ موفقیت بدون وابستگی به UI یا دیتابیس.
abstract final class StreakCalculator {
  static int current({
    required HabitModel habit,
    required Set<String> completedDateKeys,
    DateTime? today,
  }) {
    final DateTime now = _normalize(today ?? DateTime.now());
    DateTime cursor = now;
    if (!completedDateKeys.contains(JalaliHelper.dateKey(cursor))) {
      cursor = now.subtract(const Duration(days: 1));
    }
    if (!completedDateKeys.contains(JalaliHelper.dateKey(cursor))) {
      return 0;
    }

    int streak = 0;
    for (int i = 0; i < 730; i++) {
      final DateTime day = cursor.subtract(Duration(days: i));
      if (!RepeatRuleMatcher.isEligible(habit, day)) {
        continue;
      }
      if (!completedDateKeys.contains(JalaliHelper.dateKey(day))) {
        break;
      }
      streak++;
    }
    return streak;
  }

  static int best({
    required HabitModel habit,
    required Set<String> completedDateKeys,
    DateTime? today,
  }) {
    final DateTime now = _normalize(today ?? DateTime.now());
    final DateTime created = _normalize(DateTime.parse(habit.createdAt));
    int bestRun = 0;
    int run = 0;
    for (DateTime day = created;
        !day.isAfter(now);
        day = day.add(const Duration(days: 1))) {
      if (!RepeatRuleMatcher.isEligible(habit, day)) {
        continue;
      }
      if (completedDateKeys.contains(JalaliHelper.dateKey(day))) {
        run++;
        if (run > bestRun) {
          bestRun = run;
        }
      } else {
        run = 0;
      }
    }
    return bestRun;
  }

  /// درصد موفقیت در ماه شمسی جاری (۰ تا ۱۰۰).
  static int monthlySuccessRate({
    required HabitModel habit,
    required Set<String> completedDateKeys,
    DateTime? today,
  }) {
    final DateTime now = _normalize(today ?? DateTime.now());
    final Jalali jalali = Jalali.fromDateTime(now);
    final DateTime start = Jalali(jalali.year, jalali.month, 1).toDateTime();
    final int length = JalaliHelper.jalaliMonthLength(
      jalali.year,
      jalali.month,
    );
    int eligible = 0;
    int done = 0;
    for (int i = 0; i < length; i++) {
      final DateTime day = start.add(Duration(days: i));
      if (day.isAfter(now) || !RepeatRuleMatcher.isEligible(habit, day)) {
        continue;
      }
      eligible++;
      if (completedDateKeys.contains(JalaliHelper.dateKey(day))) {
        done++;
      }
    }
    if (eligible == 0) {
      return 0;
    }
    return ((done / eligible) * 100).round();
  }

  static DateTime _normalize(DateTime value) =>
      DateTime(value.year, value.month, value.day);
}
