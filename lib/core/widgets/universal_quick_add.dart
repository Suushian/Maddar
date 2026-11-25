import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:madaar/core/database/database_providers.dart';
import 'package:madaar/core/database/models.dart';
import 'package:madaar/core/database/repositories.dart';
import 'package:madaar/core/theme/app_colors.dart';
import 'package:madaar/core/utils/currency_formatter.dart';
import 'package:madaar/core/utils/haptics.dart';
import 'package:madaar/core/utils/jalali_helper.dart';

/// شیت چهارتبه ثبت سریع؛ทุก تب مستقیماً به Repository مربوطه متصل است.
class UniversalQuickAdd extends StatefulWidget {
  const UniversalQuickAdd({super.key, this.initialTab = 0});

  final int initialTab;

  static Future<void> show(BuildContext context, {int initialTab = 0}) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext sheetContext) =>
          UniversalQuickAdd(initialTab: initialTab),
    );
  }

  @override
  State<UniversalQuickAdd> createState() => _UniversalQuickAddState();
}

class _UniversalQuickAddState extends State<UniversalQuickAdd>
    with SingleTickerProviderStateMixin {
  late final TabController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TabController(
      length: 4,
      vsync: this,
      initialIndex: widget.initialTab < 0
          ? 0
          : (widget.initialTab > 3 ? 3 : widget.initialTab),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double keyboard = MediaQuery.viewInsetsOf(context).bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: keyboard),
      child: Container(
        height: MediaQuery.sizeOf(context).height * 0.72,
        decoration: BoxDecoration(
          color: AppColors.bgElevated(context).withValues(alpha: 0.97),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          border: Border.all(color: AppColors.borderSubtle(context)),
        ),
        child: Column(
          children: <Widget>[
            Text(
              'ثبت سریع',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            TabBar(
              controller: _controller,
              labelColor: AppColors.brand(context),
              unselectedLabelColor: AppColors.textMuted(context),
              indicatorColor: AppColors.brand(context),
              dividerColor: AppColors.borderSubtle(context),
              labelStyle: const TextStyle(
                fontFamily: 'Vazirmatn',
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
              tabs: const <Widget>[
                Tab(text: 'کار'),
                Tab(text: 'تراکنش'),
                Tab(text: 'حس امروز'),
                Tab(text: 'عادت'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: <Widget>[
                  _TaskQuickForm(),
                  _TransactionQuickForm(),
                  _JournalQuickForm(),
                  _HabitQuickForm(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// نگهبان مشترک بارگذاری Repositoryها در داخل شیت.
class _RepoGate<T> extends StatelessWidget {
  const _RepoGate({required this.value, required this.child});

  final AsyncValue<T> value;
  final Widget Function(T repo) child;

  @override
  Widget build(BuildContext context) => value.when(
        data: child,
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (Object error, StackTrace stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text('خطا در دسترسی به دادهها: $error'),
          ),
        ),
      );
}

abstract final class _QuickFormStyle {
  static InputDecoration input(BuildContext context, String hint) =>
      InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: AppColors.bgSurface(context),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      );

  static Widget scaffold({
    required BuildContext context,
    required GlobalKey<FormState> formKey,
    required String title,
    required List<Widget> fields,
    required String actionLabel,
    required Future<void> Function() onSave,
  }) {
    return Form(
      key: formKey,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            ...fields,
            const Spacer(),
            FilledButton(
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: () async {
                if (!(formKey.currentState?.validate() ?? false)) {
                  return;
                }
                await Haptics.success();
                await onSave();
              },
              child: Text(actionLabel),
            ),
          ],
        ),
      ),
    );
  }
}

class _TaskQuickForm extends ConsumerStatefulWidget {
  const _TaskQuickForm();

  @override
  ConsumerState<_TaskQuickForm> createState() => _TaskQuickFormState();
}

class _TaskQuickFormState extends ConsumerState<_TaskQuickForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _title = TextEditingController();
  String _pillar = 'work';
  bool _today = true;
  int _priority = 0;

  static const Map<String, String> _pillars = <String, String>{
    'work': 'کار و رشد',
    'health': 'سلامتی',
    'personal': 'شخصی',
    'learning': 'یادگیری',
  };

  @override
  void dispose() {
    _title.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => _RepoGate<TasksRepository>(
        value: ref.watch(tasksRepositoryProvider),
        child: (TasksRepository repo) => _QuickFormStyle.scaffold(
          context: context,
          formKey: _formKey,
          title: 'کار جدید',
          actionLabel: 'ذخیره کار',
          onSave: () async {
            await repo.insertTask(
              title: _title.text.trim(),
              pillar: _pillar,
              dueDate: _today
                  ? JalaliHelper.dateKey(DateTime.now())
                  : null,
              priority: _priority,
            );
            if (mounted) {
              Navigator.of(context).pop();
            }
          },
          fields: <Widget>[
            TextFormField(
              controller: _title,
              autofocus: true,
              decoration: _QuickFormStyle.input(context, 'عنوان کار را بنویسید…'),
              validator: (String? value) => (value?.trim().isEmpty ?? true)
                  ? 'عنوان کار لازم است'
                  : null,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: <Widget>[
                for (final MapEntry<String, String> entry in _pillars.entries)
                  ChoiceChip(
                    label: Text(entry.value),
                    selected: _pillar == entry.key,
                    onSelected: (_) => setState(() => _pillar = entry.key),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            FilterChip(
              label: const Text('مهم'),
              selected: _priority == 1,
              onSelected: (bool selected) =>
                  setState(() => _priority = selected ? 1 : 0),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('کار امروز'),
              value: _today,
              onChanged: (bool value) => setState(() => _today = value),
            ),
          ],
        ),
      );
}

class _TransactionQuickForm extends ConsumerStatefulWidget {
  const _TransactionQuickForm();

  @override
  ConsumerState<_TransactionQuickForm> createState() =>
      _TransactionQuickFormState();
}

class _TransactionQuickFormState extends ConsumerState<_TransactionQuickForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _amount = TextEditingController();
  String _category = 'food';

  static const Map<String, String> _categories = <String, String>{
    'food': 'خوراک',
    'transport': 'رفت و آمد',
    'home': 'خانه',
    'health': 'سلامت',
    'shopping': 'خرید',
    'entertainment': 'تفریح',
    'other': 'متفرقه',
  };

  @override
  void dispose() {
    _amount.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => _RepoGate<FinanceRepository>(
        value: ref.watch(financeRepositoryProvider),
        child: (FinanceRepository repo) => _QuickFormStyle.scaffold(
          context: context,
          formKey: _formKey,
          title: 'تراکنش مالی',
          actionLabel: 'ذخیره تراکنش',
          onSave: () async {
            await repo.addTransaction(
              amount: CurrencyFormatter.parse(_amount.text),
              type: 'expense',
              categoryId: _category,
            );
            if (mounted) {
              Navigator.of(context).pop();
            }
          },
          fields: <Widget>[
            TextFormField(
              controller: _amount,
              autofocus: true,
              keyboardType: TextInputType.number,
              decoration: _QuickFormStyle.input(context, 'مبلغ به تومان…'),
              validator: (String? value) {
                final int amount = CurrencyFormatter.parse(value ?? '');
                return amount <= 0 ? 'مبلغ معتبر وارد کنید' : null;
              },
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: <Widget>[
                for (final MapEntry<String, String> entry
                    in _categories.entries)
                  ChoiceChip(
                    label: Text(entry.value),
                    selected: _category == entry.key,
                    onSelected: (_) => setState(() => _category = entry.key),
                  ),
              ],
            ),
          ],
        ),
      );
}

class _JournalQuickForm extends ConsumerStatefulWidget {
  const _JournalQuickForm();

  @override
  ConsumerState<_JournalQuickForm> createState() => _JournalQuickFormState();
}

class _JournalQuickFormState extends ConsumerState<_JournalQuickForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _content = TextEditingController();

  @override
  void dispose() {
    _content.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => _RepoGate<JournalRepository>(
        value: ref.watch(journalRepositoryProvider),
        child: (JournalRepository repo) => _QuickFormStyle.scaffold(
          context: context,
          formKey: _formKey,
          title: 'حالوهوای امروز',
          actionLabel: 'ذخیره حس',
          onSave: () async {
            await repo.upsert(
              dateKey: JalaliHelper.dateKey(DateTime.now()),
              moodScore: 4,
              energyScore: 3,
              tagsJson: '[]',
              content: _content.text.trim(),
            );
            if (mounted) {
              Navigator.of(context).pop();
            }
          },
          fields: <Widget>[
            TextFormField(
              controller: _content,
              autofocus: true,
              maxLines: 5,
              decoration: _QuickFormStyle.input(
                context,
                'بهترین لحظه کوچک امروز چی بود؟',
              ),
              validator: (String? value) => (value?.trim().isEmpty ?? true)
                  ? 'چند کلمه بنویسید'
                  : null,
            ),
          ],
        ),
      );
}

class _HabitQuickForm extends ConsumerStatefulWidget {
  const _HabitQuickForm();

  @override
  ConsumerState<_HabitQuickForm> createState() => _HabitQuickFormState();
}

class _HabitQuickFormState extends ConsumerState<_HabitQuickForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _title = TextEditingController();
  String _repeat = 'daily';

  static const Map<String, String> _repeats = <String, String>{
    'daily': 'هر روز',
    'weekly': 'روزهای هفته',
    'alternate': 'زوج/فرد',
  };

  @override
  void dispose() {
    _title.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => _RepoGate<HabitsRepository>(
        value: ref.watch(habitsRepositoryProvider),
        child: (HabitsRepository repo) => _QuickFormStyle.scaffold(
          context: context,
          formKey: _formKey,
          title: 'عادت جدید',
          actionLabel: 'ذخیره عادت',
          onSave: () async {
            await repo.insertHabit(
              title: _title.text.trim(),
              iconCode: 'sparkles',
              colorHex: '#10B981',
              repeatType: _repeat,
              weekdayMask: _repeat == 'weekly' ? 127 : null,
              repeatAnchorDate: _repeat == 'alternate'
                  ? JalaliHelper.dateKey(DateTime.now())
                  : null,
            );
            if (mounted) {
              Navigator.of(context).pop();
            }
          },
          fields: <Widget>[
            TextFormField(
              controller: _title,
              autofocus: true,
              decoration: _QuickFormStyle.input(context, 'نام عادت…'),
              validator: (String? value) => (value?.trim().isEmpty ?? true)
                  ? 'نام عادت لازم است'
                  : null,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: <Widget>[
                for (final MapEntry<String, String> entry in _repeats.entries)
                  ChoiceChip(
                    label: Text(entry.value),
                    selected: _repeat == entry.key,
                    onSelected: (_) => setState(() => _repeat = entry.key),
                  ),
              ],
            ),
          ],
        ),
      );
}
