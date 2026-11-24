import 'package:flutter_test/flutter_test.dart';
import 'package:madaar/core/database/models.dart';
import 'package:madaar/core/utils/budget_calculator.dart';
import 'package:madaar/core/utils/repeat_rule_matcher.dart';
import 'package:madaar/core/utils/streak_calculator.dart';

void main() {
  final DateTime today = DateTime(2026, 11, 24);

  HabitModel dailyHabit({String repeatType = 'daily', int? mask}) => HabitModel(
        id: 1,
        title: 'آب خوردن',
        iconCode: 'drop',
        colorHex: '#10B981',
        repeatType: repeatType,
        weekdayMask: mask,
        repeatAnchorDate: repeatType == 'alternate' ? '2026-11-20' : null,
        sortOrder: 0,
        isArchived: false,
        createdAt: '2026-01-01T00:00:00.000Z',
      );

  group('RepeatRuleMatcher', () {
    test('daily هر روز را مجاز میداند', () {
      expect(RepeatRuleMatcher.isEligible(dailyHabit(), today), isTrue);
    });

    test('weekly فقط بیتهای تنظیمشده را مجاز میداند', () {
      final HabitModel habit = dailyHabit(repeatType: 'weekly', mask: 1);
      expect(RepeatRuleMatcher.isEligible(habit, today), isFalse);
    });

    test('alternate پاریته مطلق را حفظ میکند', () {
      final HabitModel habit = dailyHabit(repeatType: 'alternate');
      expect(RepeatRuleMatcher.isEligible(habit, DateTime(2026, 11, 20)), isTrue);
      expect(RepeatRuleMatcher.isEligible(habit, DateTime(2026, 11, 21)), isFalse);
      expect(RepeatRuleMatcher.isEligible(habit, DateTime(2026, 11, 22)), isTrue);
    });
  });

  group('StreakCalculator', () {
    test('زنجیره فعلی سه روز متوالی را میشمارد', () {
      final Set<String> done = <String>{
        '2026-11-22',
        '2026-11-23',
        '2026-11-24',
      };
      expect(
        StreakCalculator.current(
          habit: dailyHabit(),
          completedDateKeys: done,
          today: today,
        ),
        3,
      );
    });

    test('اگر امروز و دیروز تیک نخورده باشد زنجیره صفر است', () {
      expect(
        StreakCalculator.current(
          habit: dailyHabit(),
          completedDateKeys: const <String>{'2026-11-20'},
          today: today,
        ),
        0,
      );
    });

    test('بهترین رکورد و نرخ ماهانه محاسبه میشوند', () {
      final Set<String> done = <String>{
        '2026-11-20',
        '2026-11-21',
        '2026-11-22',
      };
      expect(
        StreakCalculator.best(
          habit: dailyHabit(),
          completedDateKeys: done,
          today: today,
        ),
        3,
      );
      final int rate = StreakCalculator.monthlySuccessRate(
        habit: dailyHabit(),
        completedDateKeys: done,
        today: today,
      );
      expect(rate, greaterThan(0));
      expect(rate, lessThanOrEqualTo(100));
    });
  });

  group('BudgetCalculator', () {
    test('بودجه منفی نمیشود', () {
      expect(
        BudgetCalculator.safeToSpend(
          monthlyBudget: 1000000,
          spent: 800000,
          unpaidBills: 400000,
        ),
        0,
      );
    });

    test('پیشنهاد روزانه گرد به هزار تومان است', () {
      expect(
        BudgetCalculator.perDay(
          monthlyBudget: 2000000,
          spent: 500000,
          unpaidBills: 0,
          remainingDays: 10,
        ),
        150000,
      );
    });
  });
}
