import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:madaar/core/database/database_providers.dart';
import 'package:madaar/core/database/models.dart';
import 'package:madaar/core/database/repositories.dart';
import 'package:madaar/core/theme/app_colors.dart';
import 'package:madaar/core/utils/budget_calculator.dart';
import 'package:madaar/core/utils/currency_formatter.dart';
import 'package:madaar/core/utils/jalali_helper.dart';
import 'package:madaar/core/widgets/async_repo_view.dart';
import 'package:madaar/core/widgets/bento_card.dart';
import 'package:madaar/core/widgets/finance_forms.dart';
import 'package:madaar/core/widgets/module_header.dart';

class FinancePage extends ConsumerWidget {
  const FinancePage({super.key});

  static const Map<String, String> _categoryLabels = <String, String>{
    'food': 'خوراک',
    'transport': 'حملونقل',
    'home': 'خانه',
    'health': 'سلامت',
    'shopping': 'خرید روزمره',
    'entertainment': 'تفریح',
    'income': 'حقوق و درآمد',
    'savings': 'پسانداز',
    'other': 'متفرقه',
  };

  static const List<Color> _chartColors = <Color>[
    Color(0xFF38BDF8),
    Color(0xFFF59E0B),
    Color(0xFFC084FC),
    Color(0xFF34D399),
    Color(0xFFF472B6),
    Color(0xFF94A3B8),
    Color(0xFFFBBF24),
    Color(0xFF818CF8),
    Color(0xFF2DD4BF),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Color accent = AppColors.accent(context, MadaarAccent.income);
    final AsyncValue<FinanceRepository> repoAsync =
        ref.watch(financeRepositoryProvider);
    final AsyncValue<SettingsRepository> settingsRepoAsync =
        ref.watch(settingsRepositoryProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: <Widget>[
            ModuleHeader(
              title: 'جیب هوشمند',
              subtitle: 'ثبت هزینه در سه ثانیه',
              accent: accent,
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  IconButton(
                    tooltip: 'ثبت تراکنش',
                    onPressed: () => _addTransaction(context, repoAsync),
                    icon: const Icon(Icons.add_circle_outline_rounded),
                  ),
                  IconButton(
                    tooltip: 'تعریف قسط ثابت',
                    onPressed: () => _addBill(context, repoAsync),
                    icon: const Icon(Icons.receipt_long_outlined),
                  ),
                ],
              ),
            ),
            Expanded(
              child: AsyncRepoView<FinanceRepository>(
                value: repoAsync,
                builder: (FinanceRepository repo) => StreamBuilder<List<TransactionModel>>(
                  stream: repo.watchTransactions(),
                  builder: (
                    BuildContext context,
                    AsyncSnapshot<List<TransactionModel>> txSnapshot,
                  ) {
                    return StreamBuilder<List<BillModel>>(
                      stream: repo.watchBills(),
                      builder: (
                        BuildContext context,
                        AsyncSnapshot<List<BillModel>> billSnapshot,
                      ) {
                        return settingsRepoAsync.when(
                              data: (SettingsRepository settingsRepo) =>
                                  StreamBuilder<SettingsModel>(
                                stream: settingsRepo.watch(),
                                builder: (
                                  BuildContext context,
                                  AsyncSnapshot<SettingsModel> settingsSnapshot,
                                ) {
                                  return _body(
                                    context,
                                    repo: repo,
                                    transactions:
                                        txSnapshot.data ?? const <TransactionModel>[],
                                    bills:
                                        billSnapshot.data ?? const <BillModel>[],
                                    settings: settingsSnapshot.data ??
                                        const SettingsModel(
                                          updatedAt:
                                              '1970-01-01T00:00:00.000Z',
                                        ),
                                  );
                                },
                              ),
                              loading: () => const SizedBox.shrink(),
                              error: (_, __) => const SizedBox.shrink(),
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

  Widget _body(
    BuildContext context, {
    required FinanceRepository repo,
    required List<TransactionModel> transactions,
    required List<BillModel> bills,
    required SettingsModel settings,
  }) {
    final Color accent = AppColors.accent(context, MadaarAccent.income);
    final String month = JalaliHelper.jalaliMonthKey(DateTime.now());
    final List<TransactionModel> monthTx = transactions
        .where(
          (tx) =>
              tx.type == 'expense' &&
              JalaliHelper.jalaliMonthKey(
                    DateTime.tryParse(tx.transactedAt)?.toLocal() ??
                        DateTime.fromMillisecondsSinceEpoch(0),
                  ) ==
                  month,
        )
        .toList();
    final int spent = monthTx.fold<int>(0, (sum, tx) => sum + tx.amount);
    final int unpaidBills = bills
        .where((bill) => bill.lastPaidJalaliMonth != month)
        .fold<int>(0, (sum, bill) => sum + bill.amount);
    final int budget = settings.monthlyBudget ?? 0;
    final int safe = budget > 0
        ? BudgetCalculator.safeToSpend(
            monthlyBudget: budget,
            spent: spent,
            unpaidBills: unpaidBills,
          )
        : 0;
    final int remainingDays = JalaliHelper.jalaliMonthLength(
          JalaliHelper.toJalali(DateTime.now()).year,
          JalaliHelper.toJalali(DateTime.now()).month,
        ) -
        JalaliHelper.toJalali(DateTime.now()).day +
        1;
    final int perDay = budget > 0
        ? BudgetCalculator.perDay(
            monthlyBudget: budget,
            spent: spent,
            unpaidBills: unpaidBills,
            remainingDays: remainingDays,
          )
        : 0;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: BentoCard(
                accent: accent,
                child: _stat(
                  context,
                  'قابل خرج امروز',
                  budget > 0
                      ? CurrencyFormatter.format(safe)
                      : 'بودجه تنظیم نشده',
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: BentoCard(
                child: _stat(
                  context,
                  'سهم هر روز',
                  budget > 0
                      ? CurrencyFormatter.format(perDay)
                      : '—',
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        BentoCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'ترکیب هزینههای $month',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              if (monthTx.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(
                    child: Text('هنوز هزینهای ثبت نشده است'),
                  ),
                )
              else
                SizedBox(
                  height: 170,
                  child: PieChart(
                    PieChartData(
                      sections: _pieSections(monthTx),
                      sectionsSpace: 2,
                      centerSpaceRadius: 44,
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        BentoCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'روند ۷ روز اخیر',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 150,
                child: LineChart(
                  LineChartData(
                    lineBarsData: <LineChartBarData>[
                      LineChartBarData(
                        spots: _weeklySpots(transactions),
                        isCurved: true,
                        color: accent,
                        barWidth: 2.5,
                        belowBarData: BarAreaData(
                          show: true,
                          color: accent.withValues(alpha: 0.12),
                        ),
                        dotData: const FlDotData(show: false),
                      ),
                    ],
                    titlesData: const FlTitlesData(show: false),
                    gridData: const FlGridData(show: false),
                    borderData: FlBorderData(show: false),
                    minY: 0,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        if (bills.isNotEmpty)
          BentoCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'قبوض ثابت',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                for (final BillModel bill in bills)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(bill.title),
                    subtitle: Text(
                      'روز ${JalaliHelper.faDigits(bill.dueDay)} هر ماه · '
                      '${CurrencyFormatter.format(bill.amount)}',
                    ),
                    trailing: bill.lastPaidJalaliMonth == month
                        ? const Icon(Icons.check_circle_rounded,
                            color: Colors.green)
                        : FilledButton.tonal(
                            onPressed: () =>
                                repo.markBillPaid(bill.id, month),
                            child: const Text('پرداخت شد'),
                          ),
                  ),
              ],
            ),
          ),
        const SizedBox(height: 12),
        BentoCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'آخرین تراکنشها',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              for (final TransactionModel tx
                  in transactions.take(8))
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(tx.note ?? _categoryLabels[tx.categoryId] ??
                      tx.categoryId),
                  subtitle: Text(
                    '${JalaliHelper.shortDate(
                      DateTime.tryParse(tx.transactedAt)?.toLocal() ??
                          DateTime.now(),
                    )} · ${_categoryLabels[tx.categoryId] ?? tx.categoryId}',
                  ),
                  trailing: Text(
                    '${tx.type == 'income' ? '+' : '−'}${CurrencyFormatter.format(tx.amount)}',
                    style: TextStyle(
                      color: tx.type == 'income' ? Colors.green : accent,
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 80),
      ],
    );
  }

  static Widget _stat(BuildContext context, String label, String value) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(label, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 8),
          Text(value, style: Theme.of(context).textTheme.titleMedium),
        ],
      );

  static List<PieChartSectionData> _pieSections(List<TransactionModel> tx) {
    final Map<String, int> totals = <String, int>{};
    for (final TransactionModel item in tx) {
      totals[item.categoryId] =
          (totals[item.categoryId] ?? 0) + item.amount;
    }
    final List<MapEntry<String, int>> entries = totals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return <PieChartSectionData>[
      for (int i = 0; i < entries.length; i++)
        PieChartSectionData(
          value: entries[i].value.toDouble(),
          color: _chartColors[i % _chartColors.length],
          radius: 34,
          title: '',
          showTitle: false,
        ),
    ];
  }

  static List<FlSpot> _weeklySpots(List<TransactionModel> transactions) {
    final DateTime today = DateTime.now();
    return <FlSpot>[
      for (int i = 6; i >= 0; i--)
        FlSpot(
          (6 - i).toDouble(),
          transactions
              .where(
                (tx) => tx.type == 'expense' &&
                    _sameDay(
                      DateTime.tryParse(tx.transactedAt)?.toLocal(),
                      DateTime(today.year, today.month, today.day - i),
                    ),
              )
              .fold<int>(0, (sum, tx) => sum + tx.amount)
              .toDouble(),
        ),
    ];
  }

  static bool _sameDay(DateTime? a, DateTime b) =>
      a != null && a.year == b.year && a.month == b.month && a.day == b.day;

  void _addTransaction(
    BuildContext context,
    AsyncValue<FinanceRepository> repoAsync,
  ) {
    final FinanceRepository? repo = repoAsync.value;
    if (repo == null) {
      return;
    }
    FinanceEntrySheet.show(
      context,
      onSave: ({
        required String note,
        required int amount,
        required String categoryId,
        required DateTime transactedAt,
        required String type,
      }) =>
          repo.addTransaction(
        amount: amount,
        type: type,
        categoryId: categoryId,
        note: note,
        transactedAt: transactedAt,
      ),
    );
  }

  void _addBill(BuildContext context, AsyncValue<FinanceRepository> repoAsync) {
    final FinanceRepository? repo = repoAsync.value;
    if (repo == null) {
      return;
    }
    final TextEditingController title = TextEditingController();
    final TextEditingController amount = TextEditingController();
    final TextEditingController day = TextEditingController(text: '1');
    showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: const Text('قسط ثابت'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            TextField(
              controller: title,
              decoration: const InputDecoration(labelText: 'عنوان'),
            ),
            TextField(
              controller: amount,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'مبلغ'),
            ),
            TextField(
              controller: day,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'روز سررسید (۱..۳۱)'),
            ),
          ],
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('لغو'),
          ),
          FilledButton(
            onPressed: () async {
              final int? value = int.tryParse(amount.text.trim());
              final int? dueDay = int.tryParse(day.text.trim());
              if (value == null || dueDay == null || title.text.trim().isEmpty) {
                return;
              }
              await repo.addBill(
                title: title.text.trim(),
                amount: value,
                dueDay: dueDay,
              );
              if (dialogContext.mounted) {
                Navigator.of(dialogContext).pop();
              }
            },
            child: const Text('ذخیره'),
          ),
        ],
      ),
    );
  }
}
