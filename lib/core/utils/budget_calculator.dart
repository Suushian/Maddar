import 'dart:math';

/// بودجه امن ماهانه: «امروز میتونی تا X خرج کنی تا آخر ماه تو مدار بمونی».
abstract final class BudgetCalculator {
  static int safeToSpend({
    required int monthlyBudget,
    required int spent,
    required int unpaidBills,
  }) {
    return max(0, monthlyBudget - spent - unpaidBills);
  }

  /// پیشنهاد روزانه گردشده به ۱۰۰۰ تومان.
  static int perDay({
    required int monthlyBudget,
    required int spent,
    required int unpaidBills,
    required int remainingDays,
  }) {
    final int safe = safeToSpend(
      monthlyBudget: monthlyBudget,
      spent: spent,
      unpaidBills: unpaidBills,
    );
    final int days = max(1, remainingDays);
    return (safe / days).floor() ~/ 1000 * 1000;
  }
}
