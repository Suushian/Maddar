import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:madaar/core/database/app_database.dart';
import 'package:madaar/core/database/database_providers.dart';
import 'package:madaar/core/database/repositories.dart';
import 'package:madaar/core/widgets/universal_quick_add.dart';

void main() {
  late AppDatabase db;
  late TasksRepository tasks;
  late FinanceRepository finance;
  late JournalRepository journal;
  late HabitsRepository habits;

  setUp(() async {
    db = AppDatabase.memory();
    tasks = TasksRepository(db);
    finance = FinanceRepository(db);
    journal = JournalRepository(db);
    habits = HabitsRepository(db);
    await db.customSelect('SELECT name FROM sqlite_master').get();
  });

  tearDown(() async {
    tasks.dispose();
    finance.dispose();
    journal.dispose();
    habits.dispose();
    await db.close();
  });

  Widget wrap() => ProviderScope(
        overrides: <Override>[
          tasksRepositoryProvider.overrideWith((ref) => Future<TasksRepository>.value(tasks)),
          financeRepositoryProvider.overrideWith((ref) => Future<FinanceRepository>.value(finance)),
          journalRepositoryProvider.overrideWith((ref) => Future<JournalRepository>.value(journal)),
          habitsRepositoryProvider.overrideWith((ref) => Future<HabitsRepository>.value(habits)),
        ],
        child: const MaterialApp(
          home: Scaffold(body: _OpenSheetButton()),
        ),
      );

  testWidgets('تب کار، کار واقعی را در Repository ذخیره میکند',
      (WidgetTester tester) async {
    await tester.pumpWidget(wrap());
    await tester.tap(find.text('باز کردن شیت'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).first, 'گزارش هفتگی');
    await tester.tap(find.text('ذخیره کار'));
    await tester.pumpAndSettle();

    final saved = await tasks.getAll();
    expect(saved.length, 1);
    expect(saved.first.title, 'گزارش هفتگی');
    expect(find.text('ثبت سریع'), findsNothing);
  });

  testWidgets('تب تراکنش، مبلغ فارسی را به تراکنش تبدیل میکند',
      (WidgetTester tester) async {
    await tester.pumpWidget(wrap());
    await tester.tap(find.text('باز کردن شیت'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('تراکنش'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).first, '۱۲۵٬۰۰۰');
    await tester.tap(find.text('ذخیره تراکنش'));
    await tester.pumpAndSettle();

    final saved = await finance.getTransactions();
    expect(saved.length, 1);
    expect(saved.first.amount, 125000);
    expect(saved.first.categoryId, 'food');
  });

  testWidgets('بستن شیت بدون ذخیره، هیچ ردیفی ایجاد نمیکند',
      (WidgetTester tester) async {
    await tester.pumpWidget(wrap());
    await tester.tap(find.text('باز کردن شیت'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('حس امروز'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('ذخیره حس'));
    await tester.pumpAndSettle();

    expect((await journal.getAll()).isEmpty, true);
    expect((await habits.getAll()).isEmpty, true);
    expect((await tasks.getAll()).isEmpty, true);
  });
}

class _OpenSheetButton extends StatelessWidget {
  const _OpenSheetButton();

  @override
  Widget build(BuildContext context) => Center(
        child: FilledButton(
          onPressed: () => UniversalQuickAdd.show(context, initialTab: 0),
          child: const Text('باز کردن شیت'),
        ),
      );
}
