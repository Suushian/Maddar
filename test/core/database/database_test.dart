import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:madaar/core/database/app_database.dart';
import 'package:madaar/core/database/models.dart';
import 'package:madaar/core/database/backup_service.dart';
import 'package:madaar/core/database/repositories.dart';
import 'package:drift/drift.dart';

void main() {
  late AppDatabase db;
  late TasksRepository tasks;
  late HabitsRepository habits;
  late FinanceRepository finance;
  late JournalRepository journal;

  setUp(() async {
    db = AppDatabase.memory();
    tasks = TasksRepository(db);
    habits = HabitsRepository(db);
    finance = FinanceRepository(db);
    journal = JournalRepository(db);
    // باز کردن دیتابیس و اجرای migration.
    await db.customSelect('SELECT name FROM sqlite_master').get();
  });

  tearDown(() async {
    tasks.dispose();
    habits.dispose();
    finance.dispose();
    journal.dispose();
    await db.close();
  });

  test('هفت جدول و سه ایندکس اصلی ساخته میشوند', () async {
    final List<QueryRow> rows = await db
        .customSelect("SELECT name FROM sqlite_master WHERE type='table'")
        .get();
    final Set<String> names =
        rows.map((row) => row.readString('name')).toSet();
    for (final String table in <String>[
      'tasks',
      'habits',
      'habit_logs',
      'transactions',
      'recurring_bills',
      'journal_entries',
      'app_settings',
    ]) {
      expect(names, contains(table));
    }
    final List<QueryRow> settings = await db
        .customSelect('SELECT id, theme_mode FROM app_settings')
        .get();
    expect(settings.length, 1);
    expect(settings.first.readString('theme_mode'), 'dark');
  });

  test('حداکثر سه تمرکز بهازای هر روز اعمال میشود', () async {
    const String day = '2026-11-24';
    final List<int> ids = <int>[];
    for (int i = 0; i < 3; i++) {
      ids.add(
        await tasks.insertTask(title: 'کار $i', pillar: 'work', dueDate: day),
      );
    }
    for (final int id in ids) {
      await tasks.setTopFocus(id, day);
    }
    expect((await tasks.getFocusForDate(day)).length, 3);

    final int fourth =
        await tasks.insertTask(title: 'چهارم', pillar: 'work', dueDate: day);
    expect(
      () => tasks.setTopFocus(fourth, day),
      throwsA(isA<StateError>()),
    );
    expect((await tasks.getFocusForDate(day)).length, 3);
  });

  test('تیک عادت بهصورت upsert و toggle کار میکند', () async {
    final int habitId = await habits.insertHabit(
      title: 'آب خوردن',
      iconCode: 'drop',
      colorHex: '#10B981',
      repeatType: 'daily',
    );
    await habits.toggleLog(habitId, '2026-11-24');
    expect((await habits.getLogs()).length, 1);
    await habits.toggleLog(habitId, '2026-11-24');
    expect((await habits.getLogs()).isEmpty, isTrue);
  });

  test('تراکنش و ژورنال با قواعد مقدار ذخیره میشوند', () async {
    await finance.addTransaction(
      amount: 125000,
      type: 'expense',
      categoryId: 'food',
    );
    expect((await finance.getTransactions()).first.amount, 125000);
    expect(
      () => finance.addTransaction(
        amount: -1,
        type: 'expense',
        categoryId: 'food',
      ),
      throwsA(isA<ArgumentError>()),
    );

    await journal.upsert(
      dateKey: '2026-11-24',
      moodScore: 4,
      energyScore: 3,
      tagsJson: '["ورزش"]',
      content: 'یک پیادهروی کوتاه',
    );
    await journal.upsert(
      dateKey: '2026-11-24',
      moodScore: 5,
      energyScore: 4,
      tagsJson: '["ورزش"]',
      content: 'ویرایش شده',
    );
    final List<JournalModel> all = await journal.getAll();
    expect(all.length, 1);
    expect(all.first.moodScore, 5);
  });

  test('بکاپ JSON تمام جدولها را بازیابی میکند', () async {
    await tasks.insertTask(title: 'کاری برای بکاپ', pillar: 'personal');
    await finance.addTransaction(
      amount: 10000,
      type: 'expense',
      categoryId: 'transport',
    );

    final Directory dir = await Directory.systemTemp.createTemp('madaar_backup');
    final BackupService backup = BackupService(db, () async => dir);
    final String json = await backup.exportToJson();

    await db.clearAll();
    expect((await tasks.getAll()).isEmpty, isTrue);

    await backup.importFromJson(json);
    expect((await tasks.getAll()).length, 1);
    expect((await finance.getTransactions()).length, 1);
    await dir.delete(recursive: true);
  });
}
