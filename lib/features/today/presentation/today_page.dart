import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:madaar/core/database/database_providers.dart';
import 'package:madaar/core/database/models.dart';
import 'package:madaar/core/database/repositories.dart';
import 'package:madaar/core/theme/app_colors.dart';
import 'package:madaar/core/utils/currency_formatter.dart';
import 'package:madaar/core/utils/haptics.dart';
import 'package:madaar/core/utils/jalali_helper.dart';
import 'package:madaar/core/utils/motion.dart';
import 'package:madaar/core/utils/repeat_rule_matcher.dart';
import 'package:madaar/core/utils/streak_calculator.dart';
import 'package:madaar/core/widgets/async_repo_view.dart';
import 'package:madaar/core/widgets/bento_card.dart';
import 'package:madaar/core/widgets/module_header.dart';
import 'package:madaar/core/widgets/universal_quick_add.dart';
import 'package:madaar/features/today/application/today_summary.dart';

/// مرکز فرماندهی امروز: تمام ارقام از استریمهای Drift میآیند.
class TodayPage extends ConsumerWidget {
  const TodayPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final DateTime now = DateTime.now();
    final Color tasksColor = AppColors.accent(context, MadaarAccent.tasks);
    final Color habitsColor = AppColors.accent(context, MadaarAccent.habits);
    final Color journalColor = AppColors.accent(context, MadaarAccent.journal);
    final AsyncValue<TodaySummary> summaryAsync =
        ref.watch(todaySummaryProvider);
    final TodaySummary summary = summaryAsync.value ??
        const TodaySummary(
          progressPercent: 0,
          focusCount: 0,
          doneHabits: 0,
          eligibleHabits: 0,
          spentToday: 0,
          moodScore: null,
        );

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: <Widget>[
            SliverToBoxAdapter(
              child: ModuleHeader(
                title: JalaliHelper.greeting(now),
                subtitle: JalaliHelper.fullDate(now),
              ),
            ),
            SliverToBoxAdapter(
              child: Motion.entrance(context, Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: <Widget>[
                    _ProgressRing(percent: summary.progressPercent),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'پیشرفت امروز',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${JalaliHelper.faDigits(summary.doneHabits)} از '
                            '${JalaliHelper.faDigits(summary.eligibleHabits)} عادت '
                            'و ${JalaliHelper.faDigits(summary.focusCount)} تمرکز',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ), 0),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 20)),
            SliverToBoxAdapter(
              child: Motion.entrance(context, Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: BentoCard(
                  accent: tasksColor,
                  onTap: () => UniversalQuickAdd.show(context, initialTab: 0),
                  child: Row(
                    children: <Widget>[
                      Icon(Icons.auto_awesome_rounded, color: tasksColor),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              '۳ تمرکز طلایی امروز',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${JalaliHelper.faDigits(summary.focusCount)} کار پین شده است',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.add_rounded, size: 20),
                    ],
                  ),
                ),
              ), 1),
            ),
            SliverToBoxAdapter(
              child: Motion.entrance(context, Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                child: AsyncRepoView<TasksRepository>(
                  value: ref.watch(tasksRepositoryProvider),
                  builder: (TasksRepository repo) => StreamBuilder<
                      List<TaskModel>>(
                    stream: repo.watchFocus(JalaliHelper.dateKey(now)),
                    builder: (
                      BuildContext context,
                      AsyncSnapshot<List<TaskModel>> snapshot,
                    ) {
                      final List<TaskModel> focus =
                          snapshot.data ?? const <TaskModel>[];
                      if (focus.isEmpty) {
                        return const SizedBox.shrink();
                      }
                      return Column(
                        children: <Widget>[
                          for (final TaskModel task in focus)
                            CheckboxListTile(
                              contentPadding: EdgeInsets.zero,
                              value: task.isCompleted,
                              onChanged: (_) async {
                                await Haptics.toggle();
                                await repo.toggleCompleted(task.id);
                              },
                              title: Text(
                                task.title,
                                style: TextStyle(
                                  decoration: task.isCompleted
                                      ? TextDecoration.lineThrough
                                      : null,
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                ),
              ), 2),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 12)),
            SliverToBoxAdapter(
              child: Motion.entrance(context, Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: BentoCard(
                  accent: habitsColor,
                  onTap: () => UniversalQuickAdd.show(context, initialTab: 3),
                  child: Row(
                    children: <Widget>[
                      Icon(Icons.local_fire_department_rounded,
                          color: habitsColor),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              'عادتهای امروز',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${JalaliHelper.faDigits(summary.doneHabits)} عادت انجام شد',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_left_rounded),
                    ],
                  ),
                ),
              ), 3),
            ),
            SliverToBoxAdapter(
              child: AsyncRepoView<HabitsRepository>(
                value: ref.watch(habitsRepositoryProvider),
                builder: (HabitsRepository repo) => _HabitStrip(
                  repo: repo,
                  now: now,
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 12)),
            SliverToBoxAdapter(
              child: Motion.entrance(context, Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: BentoCard(
                        height: 132,
                        onTap: () =>
                            UniversalQuickAdd.show(context, initialTab: 1),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              'جیب امروز',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const Spacer(),
                            Text(
                              CurrencyFormatter.format(summary.spentToday),
                              style: Theme.of(context).textTheme.headlineMedium,
                            ),
                            const SizedBox(height: 4),
                            const Text('هزینه ثبتشده امروز'),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: BentoCard(
                        height: 132,
                        accent: journalColor,
                        onTap: () =>
                            UniversalQuickAdd.show(context, initialTab: 2),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              'حالوهوای امروز',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const Spacer(),
                            Icon(Icons.self_improvement_rounded,
                                color: journalColor, size: 30),
                            const SizedBox(height: 4),
                            Text(
                              summary.moodScore == null
                                  ? 'ثبت نشده است'
                                  : 'خلق: ${JalaliHelper.faDigits(summary.moodScore!)}/۵',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ), 4),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 28)),
          ],
        ),
      ),
    );
  }
}

class _HabitStrip extends StatelessWidget {
  const _HabitStrip({required this.repo, required this.now});

  final HabitsRepository repo;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<HabitModel>>(
      stream: repo.watchAll(),
      builder: (
        BuildContext context,
        AsyncSnapshot<List<HabitModel>> habitSnapshot,
      ) {
        final List<HabitModel> habits = (habitSnapshot.data ?? const <HabitModel>[])
            .where((habit) => RepeatRuleMatcher.isEligible(habit, now))
            .toList();
        if (habits.isEmpty) {
          return const SizedBox.shrink();
        }
        return StreamBuilder<List<HabitLogModel>>(
          stream: repo.watchLogs(),
          builder: (
            BuildContext context,
            AsyncSnapshot<List<HabitLogModel>> logSnapshot,
          ) {
            final Map<int, Set<String>> done = <int, Set<String>>{};
            for (final HabitLogModel log
                in logSnapshot.data ?? const <HabitLogModel>[]) {
              done.putIfAbsent(log.habitId, () => <String>{}).add(log.dateKey);
            }
            final String today = JalaliHelper.dateKey(now);
            return SizedBox(
              height: 68,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                reverse: true,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemCount: habits.length,
                itemBuilder: (BuildContext context, int index) {
                  final HabitModel habit = habits[index];
                  final Set<String> habitDays =
                      done[habit.id] ?? const <String>{};
                  final bool checked = habitDays.contains(today);
                  final int streak = StreakCalculator.current(
                    habit: habit,
                    completedDateKeys: habitDays,
                    today: now,
                  );
                  return Motion.spring(
                    context,
                    ActionChip(
                      avatar: Icon(
                        checked
                            ? Icons.check_circle_rounded
                            : Icons.radio_button_unchecked_rounded,
                        size: 18,
                        color: checked
                            ? AppColors.stone
                            : AppColors.textMuted(context),
                      ),
                      label: Text(
                        '${habit.title}  🔥${JalaliHelper.faDigits(streak)}',
                      ),
                      onPressed: () async {
                        await Haptics.toggle();
                        await repo.toggleLog(habit.id, today);
                      },
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}

class _ProgressRing extends StatelessWidget {
  const _ProgressRing({required this.percent});

  final int percent;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 64,
      height: 64,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          CircularProgressIndicator(
            value: (percent / 100).clamp(0.0, 1.0).toDouble(),
            strokeWidth: 6,
            backgroundColor: AppColors.borderSubtle(context),
            color: AppColors.brand(context),
          ),
          Text(
            '${JalaliHelper.faDigits(percent)}٪',
            style: Theme.of(context).textTheme.labelMedium,
          ),
        ],
      ),
    );
  }
}
