import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:madaar/core/database/database_providers.dart';
import 'package:madaar/core/database/models.dart';
import 'package:madaar/core/database/repositories.dart';
import 'package:madaar/core/theme/app_colors.dart';
import 'package:madaar/core/utils/haptics.dart';
import 'package:madaar/core/utils/motion.dart';
import 'package:madaar/core/utils/streak_calculator.dart';
import 'package:madaar/core/widgets/async_repo_view.dart';
import 'package:madaar/core/widgets/bento_card.dart';
import 'package:madaar/core/widgets/empty_state_view.dart';
import 'package:madaar/core/widgets/module_header.dart';
import 'package:madaar/features/habits/presentation/habit_form_sheet.dart';
import 'package:madaar/features/habits/presentation/habit_heatmap.dart';

class HabitsPage extends ConsumerStatefulWidget {
  const HabitsPage({super.key});

  @override
  ConsumerState<HabitsPage> createState() => _HabitsPageState();
}

class _HabitsPageState extends ConsumerState<HabitsPage> {
  int _days = 30;

  @override
  Widget build(BuildContext context) {
    final Color accent = AppColors.accent(context, MadaarAccent.habits);
    final AsyncValue<HabitsRepository> repoAsync =
        ref.watch(habitsRepositoryProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: <Widget>[
            ModuleHeader(
              title: 'ریتم و عادت‌ها',
              subtitle: 'زنجیرهها و نقشه پیوستگی',
              accent: accent,
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  for (final int value in <int>[30, 90])
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: Motion.press(
                        context,
                        ChoiceChip(
                          label: Text('$value روز'),
                          selected: _days == value,
                          onSelected: (_) => setState(() => _days = value),
                        ),
                      ),
                    ),
                  Motion.press(
                    context,
                    IconButton(
                      tooltip: 'عادت جدید',
                      onPressed: () => _openForm(repoAsync),
                      icon: const Icon(Icons.add_rounded),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: AsyncRepoView<HabitsRepository>(
                value: repoAsync,
                builder: (HabitsRepository repo) => StreamBuilder<List<HabitModel>>(
                  stream: repo.watchAll(),
                  builder: (
                    BuildContext context,
                    AsyncSnapshot<List<HabitModel>> habitsSnapshot,
                  ) {
                    final List<HabitModel> habits =
                        habitsSnapshot.data ?? const <HabitModel>[];
                    if (habits.isEmpty) {
                      return EmptyStateView(
                        icon: Icons.local_fire_department_outlined,
                        title: 'هنوز عادتی تعریف نشده',
                        message:
                            'یک عادت کوچک انتخاب کن؛ زنجیرهاش به مرور ساخته میشود.',
                        actionLabel: 'تعریف عادت',
                        accent: accent,
                        onAction: () => _openForm(repoAsync),
                      );
                    }
                    return StreamBuilder<List<HabitLogModel>>(
                      stream: repo.watchLogs(),
                      builder: (
                        BuildContext context,
                        AsyncSnapshot<List<HabitLogModel>> logsSnapshot,
                      ) {
                        final Set<String> done = (logsSnapshot.data ??
                                const <HabitLogModel>[])
                            .map((log) => log.dateKey)
                            .toSet();
                        return ListView.separated(
                          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                          itemCount: habits.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 12),
                          itemBuilder: (BuildContext context, int index) =>
                              Motion.entrance(
                            context,
                            _HabitCard(
                              habit: habits[index],
                              completedKeys: done,
                              days: _days,
                              onToggle: (String key) async {
                                await Haptics.toggle();
                                await repo.toggleLog(habits[index].id, key);
                              },
                            ),
                            index,
                            id: 'habit-${habits[index].id}',
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openForm(AsyncValue<HabitsRepository> repoAsync) {
    final HabitsRepository? repo = repoAsync.value;
    if (repo == null) {
      return;
    }
    HabitFormSheet.show(
      context,
      onSave: ({
        required String title,
        required String iconCode,
        required String colorHex,
        required String repeatType,
        int? weekdayMask,
        String? repeatAnchorDate,
      }) =>
          repo.insertHabit(
        title: title,
        iconCode: iconCode,
        colorHex: colorHex,
        repeatType: repeatType,
        weekdayMask: weekdayMask,
        repeatAnchorDate: repeatAnchorDate,
      ),
    );
  }
}

class _HabitCard extends StatelessWidget {
  const _HabitCard({
    required this.habit,
    required this.completedKeys,
    required this.days,
    required this.onToggle,
  });

  final HabitModel habit;
  final Set<String> completedKeys;
  final int days;
  final ValueChanged<String> onToggle;

  @override
  Widget build(BuildContext context) {
    final Color color = HabitHeatmapColor.of(habit.colorHex);
    final int current = StreakCalculator.current(
      habit: habit,
      completedDateKeys: completedKeys,
    );
    final int best = StreakCalculator.best(
      habit: habit,
      completedDateKeys: completedKeys,
    );
    final int rate = StreakCalculator.monthlySuccessRate(
      habit: habit,
      completedDateKeys: completedKeys,
    );

    return BentoCard(
      accent: color,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Motion.pulse(
                context,
                Icon(Icons.local_fire_department_rounded, color: color),
                id: 'habit-fire-${habit.id}',
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  habit.title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              Motion.number(
                context,
                current,
                (num value) => '🔥 ${value.round()}',
                style: Theme.of(context).textTheme.bodyMedium,
                id: 'habit-streak-${habit.id}',
              ),
            ],
          ),
          const SizedBox(height: 8),
          Motion.number(
            context,
            best,
            (num value) =>
                'بهترین: ${value.round()}  ·  موفقیت ماه: $rate٪',
            style: Theme.of(context).textTheme.bodySmall,
            id: 'habit-best-${habit.id}',
          ),
          const SizedBox(height: 12),
          HabitHeatmap(
            habit: habit,
            completedKeys: completedKeys,
            days: days,
            onDayTap: onToggle,
          ),
        ],
      ),
    );
  }
}
