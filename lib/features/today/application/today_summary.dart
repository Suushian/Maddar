import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:madaar/core/database/database_providers.dart';
import 'package:madaar/core/utils/jalali_helper.dart';
import 'package:madaar/core/utils/repeat_rule_matcher.dart';

/// خلاصه لحظهای امروز که از استریم تمام ماژولها تغذیه میشود.
class TodaySummary {
  const TodaySummary({
    required this.progressPercent,
    required this.focusCount,
    required this.doneHabits,
    required this.eligibleHabits,
    required this.spentToday,
    required this.moodScore,
  });

  final int progressPercent;
  final int focusCount;
  final int doneHabits;
  final int eligibleHabits;
  final int spentToday;
  final int? moodScore;
}

final StreamProvider<TodaySummary> todaySummaryProvider =
    StreamProvider<TodaySummary>((ref) async* {
  final tasks = await ref.watch(tasksRepositoryProvider.future);
  final habits = await ref.watch(habitsRepositoryProvider.future);
  final finance = await ref.watch(financeRepositoryProvider.future);
  final journal = await ref.watch(journalRepositoryProvider.future);

  final StreamController<TodaySummary> controller =
      StreamController<TodaySummary>.broadcast();

  Future<TodaySummary> compute() async {
    final DateTime now = DateTime.now();
    final String key = JalaliHelper.dateKey(now);
    final focus = await tasks.getFocusForDate(key);
    final allHabits = await habits.getAll();
    final logs = await habits.getLogs();
    final transactions = await finance.getTransactions();
    final mood = await journal.getForDate(key);

    final int doneHabits = logs.where((log) => log.dateKey == key).length;
    final int eligibleHabits = allHabits
        .where((habit) => RepeatRuleMatcher.isEligible(habit, now))
        .length;
    final int spentToday = transactions
        .where(
          (tx) =>
              tx.type == 'expense' &&
              JalaliHelper.dateKey(DateTime.parse(tx.transactedAt)) == key,
        )
        .fold<int>(0, (int sum, tx) => sum + tx.amount);
    final int focusDone = focus.where((task) => task.isCompleted).length;
    final int denominator = focus.length + eligibleHabits;
    final int percent = denominator == 0
        ? 0
        : ((focusDone + doneHabits) / denominator * 100).round();

    return TodaySummary(
      progressPercent: percent > 100 ? 100 : percent,
      focusCount: focus.length,
      doneHabits: doneHabits,
      eligibleHabits: eligibleHabits,
      spentToday: spentToday,
      moodScore: mood?.moodScore,
    );
  }

  Future<void> emit() async {
    try {
      if (!controller.isClosed) {
        controller.add(await compute());
      }
    } catch (_) {
      // یک شکست مقطعی نباید جریان خانه را متوقف کند.
    }
  }

  final List<StreamSubscription<void>> subscriptions = <StreamSubscription<void>>[
    tasks.changes.listen((_) => emit()),
    habits.changes.listen((_) => emit()),
    finance.changes.listen((_) => emit()),
    journal.changes.listen((_) => emit()),
  ];

  ref.onDispose(() {
    for (final StreamSubscription<void> subscription in subscriptions) {
      subscription.cancel();
    }
    controller.close();
  });

  await emit();
  yield* controller.stream;
});
