import 'package:flutter_test/flutter_test.dart';
import 'package:madaar/core/database/app_database.dart';
import 'package:madaar/core/database/models.dart';
import 'package:madaar/core/database/repositories.dart';

void main() {
  test('حذف کار با UPSERT قابل بازگردانی است', () async {
    final AppDatabase db = AppDatabase.memory();
    final TasksRepository tasks = TasksRepository(db);
    addTearDown(() async {
      tasks.dispose();
      await db.close();
    });
    await db.customSelect('SELECT name FROM sqlite_master').get();

    final int id = await tasks.insertTask(title: 'کار مهم', pillar: 'work');
    final TaskModel before = (await tasks.getAll()).first;
    await tasks.delete(id);
    expect((await tasks.getAll()).isEmpty, true);

    await tasks.restoreTask(before);
    final List<TaskModel> after = await tasks.getAll();
    expect(after.length, 1);
    expect(after.first.id, id);
    expect(after.first.title, 'کار مهم');
  });

  test('copyWith تنظیمات و کار، شناسه و تاریخ ساخت را حفظ میکند', () {
    const TaskModel task = TaskModel(
      id: 7,
      title: 'عنوان',
      pillar: 'work',
      isCompleted: false,
      priority: 0,
      isTopFocus: false,
      createdAt: '2026-11-24T00:00:00.000Z',
    );
    final TaskModel changed = task.copyWith(title: 'جدید', isCompleted: true);
    expect(changed.id, 7);
    expect(changed.createdAt, task.createdAt);
    expect(changed.title, 'جدید');
    expect(changed.isCompleted, true);

    const SettingsModel settings = SettingsModel(
      monthlyBudget: 1000,
      updatedAt: '2026-11-24T00:00:00.000Z',
    );
    final SettingsModel updated =
        settings.copyWith(biometricLockEnabled: true);
    expect(updated.monthlyBudget, 1000);
    expect(updated.biometricLockEnabled, true);
    expect(updated.id, 1);
  });
}
