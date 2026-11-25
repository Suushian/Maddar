import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:madaar/core/database/database_providers.dart';
import 'package:madaar/core/database/models.dart';
import 'package:madaar/core/database/repositories.dart';
import 'package:madaar/core/theme/app_colors.dart';
import 'package:madaar/core/utils/haptics.dart';
import 'package:madaar/core/utils/jalali_helper.dart';
import 'package:madaar/core/widgets/async_repo_view.dart';
import 'package:madaar/core/widgets/empty_state_view.dart';
import 'package:madaar/core/widgets/module_header.dart';
import 'package:madaar/core/widgets/universal_quick_add.dart';

const Map<String, String> _pillarLabels = <String, String>{
  'work': 'کار و رشد',
  'health': 'سلامتی',
  'personal': 'شخصی و خانه',
  'learning': 'یادگیری',
};

class TasksPage extends ConsumerStatefulWidget {
  const TasksPage({super.key});

  @override
  ConsumerState<TasksPage> createState() => _TasksPageState();
}

class _TasksPageState extends ConsumerState<TasksPage> {
  int _tab = 0;
  static const List<String> _tabs = <String>[
    'امروز',
    'صندوق ورودی',
    'برنامهریزیشده',
  ];

  @override
  Widget build(BuildContext context) {
    final Color accent = AppColors.accent(context, MadaarAccent.tasks);
    final AsyncValue<TasksRepository> repoAsync =
        ref.watch(tasksRepositoryProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: <Widget>[
            ModuleHeader(
              title: 'کارها',
              subtitle: 'ساده، سریع و بدون بروکراسی',
              accent: accent,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
              child: Row(
                children: <Widget>[
                  for (int i = 0; i < _tabs.length; i++)
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 3),
                        child: ChoiceChip(
                          label: Text(_tabs[i]),
                          selected: _tab == i,
                          onSelected: (_) => setState(() => _tab = i),
                          side:
                              BorderSide(color: AppColors.borderSubtle(context)),
                          selectedColor: accent.withValues(alpha: 0.18),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Expanded(
              child: AsyncRepoView<TasksRepository>(
                value: repoAsync,
                builder: (TasksRepository repo) => StreamBuilder<List<TaskModel>>(
                  stream: repo.watchAll(),
                  builder: (
                    BuildContext context,
                    AsyncSnapshot<List<TaskModel>> snapshot,
                  ) {
                    final List<TaskModel> tasks =
                        _filter(snapshot.data ?? const <TaskModel>[]);
                    if (tasks.isEmpty) {
                      return EmptyStateView(
                        icon: Icons.check_circle_outline_rounded,
                        title: 'هیچ کاری اینجا نیست',
                        message:
                            'اولین کار را با دکمه + ثبت کن تا در این لیست ببینیش.',
                        actionLabel: 'افزودن کار',
                        accent: accent,
                        onAction: () => UniversalQuickAdd.show(
                          context,
                          initialTab: 0,
                        ),
                      );
                    }
                    return ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                      itemCount: tasks.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (BuildContext context, int index) => _TaskTile(
                        task: tasks[index],
                        repo: repo,
                        accent: accent,
                      ),
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

  List<TaskModel> _filter(List<TaskModel> tasks) {
    final String today = JalaliHelper.dateKey(DateTime.now());
    switch (_tab) {
      case 0:
        return tasks
            .where(
              (task) => task.dueDate == today || task.focusDate == today,
            )
            .toList();
      case 1:
        return tasks.where((task) => task.dueDate == null).toList();
      default:
        return tasks
            .where(
              (task) =>
                  task.dueDate != null && task.dueDate!.compareTo(today) > 0,
            )
            .toList();
    }
  }
}

class _TaskTile extends StatelessWidget {
  const _TaskTile({
    required this.task,
    required this.repo,
    required this.accent,
  });

  final TaskModel task;
  final TasksRepository repo;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final Color pillarColor = _pillarColor(context, task.pillar);
    return Dismissible(
      key: ValueKey<int>(task.id),
      direction: DismissDirection.horizontal,
      background: _swipeBackground(
        context,
        alignment: Alignment.centerLeft,
        icon: Icons.check_rounded,
        label: 'انجام شد',
        color: AppColors.habits,
      ),
      secondaryBackground: _swipeBackground(
        context,
        alignment: Alignment.centerRight,
        icon: Icons.event_available_rounded,
        label: 'فردا',
        color: accent,
      ),
      confirmDismiss: (DismissDirection direction) async {
        if (direction == DismissDirection.startToEnd) {
          await Haptics.success();
          await _withUndo(
            context: context,
            repo: repo,
            before: task,
            message: 'کار انجام شد',
            action: () => repo.toggleCompleted(task.id),
          );
        } else {
          await Haptics.toggle();
          await _withUndo(
            context: context,
            repo: repo,
            before: task,
            message: 'کار به فردا منتقل شد',
            action: () => repo.snoozeToTomorrow(task.id),
          );
        }
        return false; // لیست توسط استریم دوباره ساخته میشود.
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.bgSurface(context),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderSubtle(context)),
        ),
        child: Row(
          children: <Widget>[
            GestureDetector(
              onTap: () => repo.toggleCompleted(task.id),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: task.isCompleted ? accent : Colors.transparent,
                  border: Border.all(
                    color: task.isCompleted ? accent : pillarColor,
                    width: 2,
                  ),
                ),
                child: task.isCompleted
                    ? const Icon(Icons.check, size: 16, color: Colors.white)
                    : null,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    task.title,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          decoration: task.isCompleted
                              ? TextDecoration.lineThrough
                              : null,
                          color: task.isCompleted
                              ? AppColors.textMuted(context)
                              : null,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${_pillarLabels[task.pillar] ?? task.pillar}'
                    '${task.priority == 1 ? '  ·  مهم' : ''}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: 'حذف کار',
              onPressed: () => _confirmDelete(context, repo, task),
              icon: Icon(
                Icons.delete_outline_rounded,
                color: AppColors.textMuted(context),
                size: 20,
              ),
            ),
            IconButton(
              tooltip: task.isTopFocus ? 'حذف از تمرکز' : 'تمرکز امروز',
              onPressed: () async {
                await Haptics.tap();
                if (task.isTopFocus) {
                  await repo.clearTopFocus(task.id);
                  return;
                }
                final String day = task.focusDate ??
                    JalaliHelper.dateKey(DateTime.now());
                try {
                  await repo.setTopFocus(task.id, day);
                } on StateError catch (error) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(error.message)),
                    );
                  }
                }
              },
              icon: Icon(
                task.isTopFocus
                    ? Icons.auto_awesome_rounded
                    : Icons.auto_awesome_outlined,
                color: task.isTopFocus ? accent : AppColors.textMuted(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Future<void> _confirmDelete(
    BuildContext context,
    TasksRepository repo,
    TaskModel task,
  ) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: const Text('حذف کار؟'),
        content: Text(task.title),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('لغو'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
    if (confirmed != true) {
      return;
    }
    await repo.delete(task.id);
    if (!context.mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('کار حذف شد'),
        duration: const Duration(seconds: 5),
        action: SnackBarAction(
          label: 'بازگردانی',
          onPressed: () => repo.restoreTask(task),
        ),
      ),
    );
  }

  static Color _pillarColor(BuildContext context, String pillar) {
    switch (pillar) {
      case 'work':
        return AppColors.accent(context, MadaarAccent.tasks);
      case 'health':
        return AppColors.habits;
      case 'personal':
        return AppColors.brand(context);
      default:
        return AppColors.accent(context, MadaarAccent.journal);
    }
  }

  static Widget _swipeBackground(
    BuildContext context, {
    required Alignment alignment,
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      alignment: alignment,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, color: color),
          Text(label, style: TextStyle(color: color, fontSize: 11)),
        ],
      ),
    );
  }

  static Future<void> _withUndo({
    required BuildContext context,
    required TasksRepository repo,
    required TaskModel before,
    required String message,
    required Future<void> Function() action,
  }) async {
    await action();
    if (!context.mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 5),
        action: SnackBarAction(
          label: 'بازگردانی',
          onPressed: () => repo.restoreTask(before),
        ),
      ),
    );
  }
}
