import 'dart:async';

import 'package:drift/drift.dart';
import 'package:madaar/core/database/app_database.dart';
import 'package:madaar/core/database/models.dart';
import 'package:madaar/core/utils/jalali_helper.dart';

/// استریم سطح Repository: پس از هر نوشتن، خوانندهها دوباره کوئری میزنند.
abstract class ChangeEmitter {
  final StreamController<void> _controller = StreamController<void>.broadcast();

  Stream<void> get changes => _controller.stream;

  void emitChange() {
    if (!_controller.isClosed) {
      _controller.add(null);
    }
  }

  void dispose() {
    _controller.close();
  }

  Stream<List<T>> reactive<T>(Future<List<T>> Function() read) async* {
    yield await read();
    await for (final _ in changes) {
      yield await read();
    }
  }

  /// استریم برای کوئریهای تکمقداری مانند تنظیمات.
  Stream<T> reactiveValue<T>(Future<T> Function() read) async* {
    yield await read();
    await for (final _ in changes) {
      yield await read();
    }
  }
}

class TasksRepository extends ChangeEmitter {
  TasksRepository(this._db);

  final AppDatabase _db;

  Future<List<TaskModel>> getAll() async {
    final List<QueryRow> rows = await _db
        .customSelect(
          'SELECT * FROM tasks ORDER BY is_completed ASC, '
          'CASE WHEN due_date IS NULL THEN 1 ELSE 0 END, due_date, created_at',
        )
        .get();
    return rows.map(TaskModel.fromRow).toList();
  }

  Future<List<TaskModel>> getForDate(String dateKey) async {
    final List<QueryRow> rows = await _db
        .customSelect(
          'SELECT * FROM tasks WHERE due_date = ? ORDER BY priority DESC, created_at',
          variables: <Variable<Object>>[Variable<String>(dateKey)],
        )
        .get();
    return rows.map(TaskModel.fromRow).toList();
  }

  Future<List<TaskModel>> getFocusForDate(String dateKey) async {
    final List<QueryRow> rows = await _db
        .customSelect(
          'SELECT * FROM tasks WHERE focus_date = ? AND is_top_focus = 1 '
          'ORDER BY created_at',
          variables: <Variable<Object>>[Variable<String>(dateKey)],
        )
        .get();
    return rows.map(TaskModel.fromRow).toList();
  }

  Stream<List<TaskModel>> watchAll() => reactive(getAll);

  Stream<List<TaskModel>> watchFocus(String dateKey) =>
      reactive(() => getFocusForDate(dateKey));

  Future<int> insertTask({
    required String title,
    required String pillar,
    String? note,
    String? dueDate,
    int priority = 0,
  }) async {
    if (!TaskModel.pillars.contains(pillar)) {
      throw ArgumentError.value(pillar, 'pillar', 'حوزه نامعتبر است');
    }
    await _db.customStatement(
      'INSERT INTO tasks (title, note, pillar, due_date, priority, created_at) '
      'VALUES (?, ?, ?, ?, ?, ?)',
      <dynamic>[
        title,
        note,
        pillar,
        dueDate,
        priority,
        AppDatabase.nowIso(),
      ],
    );
    emitChange();
    final List<QueryRow> rows = await _db
        .customSelect('SELECT last_insert_rowid() AS id')
        .get();
    return rows.first.readInt('id');
  }

  Future<void> toggleCompleted(int id) async {
    await _db.transaction(() async {
      final List<QueryRow> rows = await _db
          .customSelect(
            'SELECT is_completed FROM tasks WHERE id = ?',
            variables: <Variable<Object>>[Variable<int>(id)],
          )
          .get();
      if (rows.isEmpty) {
        return;
      }
      final bool done = rows.first.readInt('is_completed') == 1;
      await _db.customStatement(
        'UPDATE tasks SET is_completed = ?, completed_at = ? WHERE id = ?',
        <dynamic>[done ? 0 : 1, done ? null : AppDatabase.nowIso(), id],
      );
    });
    emitChange();
  }

  /// حداکثر ۳ کار بهازای هر روز؛ اعمال محدودیت در یک تراکنش (ADR-004).
  Future<void> setTopFocus(int taskId, String focusDate) async {
    await _db.transaction(() async {
      final List<QueryRow> current = await _db
          .customSelect(
            'SELECT focus_date, is_top_focus FROM tasks WHERE id = ?',
            variables: <Variable<Object>>[Variable<int>(taskId)],
          )
          .get();
      if (current.isEmpty) {
        throw StateError('یافت نشد task با شناسه $taskId');
      }
      final bool alreadyFocused =
          current.first.readInt('is_top_focus') == 1 &&
              current.first.readNullable<String>('focus_date') == focusDate;
      if (alreadyFocused) {
        return;
      }
      final List<QueryRow> countRows = await _db
          .customSelect(
            'SELECT COUNT(*) AS n FROM tasks WHERE focus_date = ? '
            'AND is_top_focus = 1',
            variables: <Variable<Object>>[Variable<String>(focusDate)],
          )
          .get();
      if (countRows.first.readInt('n') >= 3) {
        throw StateError('حداکثر ۳ تمرکز در روز مجاز است');
      }
      await _db.customStatement(
        'UPDATE tasks SET is_top_focus = 1, focus_date = ? WHERE id = ?',
        <dynamic>[focusDate, taskId],
      );
    });
    emitChange();
  }

  Future<void> clearTopFocus(int taskId) async {
    await _db.customStatement(
      'UPDATE tasks SET is_top_focus = 0, focus_date = NULL WHERE id = ?',
      <dynamic>[taskId],
    );
    emitChange();
  }

  Future<void> snoozeToTomorrow(int id) async {
    final String tomorrow = JalaliHelper.dateKey(
      DateTime.now().add(const Duration(days: 1)),
    );
    await _db.customStatement(
      'UPDATE tasks SET due_date = ?, focus_date = NULL, is_top_focus = 0 '
      'WHERE id = ?',
      <dynamic>[tomorrow, id],
    );
    emitChange();
  }

  /// بازگردانی وضعیت پیشین کار (Undo بعد از swipe یا حذف).
  /// UPSERT کار همیشه با همان شناسه بازگردانده میشود.
  Future<void> restoreTask(TaskModel task) async {
    await _db.customStatement(
      'INSERT INTO tasks (id, title, note, pillar, due_date, focus_date, '
      'is_top_focus, priority, is_completed, completed_at, created_at) '
      'VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?) '
      'ON CONFLICT(id) DO UPDATE SET title = excluded.title, '
      'note = excluded.note, pillar = excluded.pillar, '
      'due_date = excluded.due_date, focus_date = excluded.focus_date, '
      'is_top_focus = excluded.is_top_focus, priority = excluded.priority, '
      'is_completed = excluded.is_completed, '
      'completed_at = excluded.completed_at, created_at = excluded.created_at',
      <dynamic>[
        task.id,
        task.title,
        task.note,
        task.pillar,
        task.dueDate,
        task.focusDate,
        task.isTopFocus ? 1 : 0,
        task.priority,
        task.isCompleted ? 1 : 0,
        task.completedAt,
        task.createdAt,
      ],
    );
    emitChange();
  }

  Future<void> delete(int id) async {
    await _db.customStatement('DELETE FROM tasks WHERE id = ?', <dynamic>[id]);
    emitChange();
  }
}

class HabitsRepository extends ChangeEmitter {
  HabitsRepository(this._db);

  final AppDatabase _db;

  Future<List<HabitModel>> getAll({bool includeArchived = false}) async {
    final String where = includeArchived
        ? ''
        : 'WHERE is_archived = 0';
    final List<QueryRow> rows = await _db
        .customSelect(
          'SELECT * FROM habits $where ORDER BY sort_order, id',
        )
        .get();
    return rows.map(HabitModel.fromRow).toList();
  }

  Future<List<HabitLogModel>> getLogs() async {
    final List<QueryRow> rows =
        await _db.customSelect('SELECT * FROM habit_logs').get();
    return rows.map(HabitLogModel.fromRow).toList();
  }

  Stream<List<HabitModel>> watchAll() => reactive(() => getAll());

  Stream<List<HabitLogModel>> watchLogs() => reactive(getLogs);

  Future<int> insertHabit({
    required String title,
    required String iconCode,
    required String colorHex,
    required String repeatType,
    int? weekdayMask,
    String? repeatAnchorDate,
  }) async {
    if (!HabitModel.repeatTypes.contains(repeatType)) {
      throw ArgumentError.value(repeatType, 'repeatType', 'الگوی نامعتبر');
    }
    if (repeatType == 'weekly' &&
        (weekdayMask == null || weekdayMask < 1 || weekdayMask > 127)) {
      throw ArgumentError.value(weekdayMask, 'weekdayMask', 'بیت مجاز ۱..۱۲۷');
    }
    await _db.customStatement(
      'INSERT INTO habits (title, icon_code, color_hex, repeat_type, '
      'weekday_mask, repeat_anchor_date, created_at) VALUES (?, ?, ?, ?, ?, ?, ?)',
      <dynamic>[
        title,
        iconCode,
        colorHex,
        repeatType,
        weekdayMask,
        repeatAnchorDate,
        AppDatabase.nowIso(),
      ],
    );
    emitChange();
    return _lastInsertId();
  }

  Future<void> toggleLog(int habitId, String dateKey) async {
    await _db.transaction(() async {
      final List<QueryRow> existing = await _db
          .customSelect(
            'SELECT id FROM habit_logs WHERE habit_id = ? AND date_key = ?',
            variables: <Variable<Object>>[
              Variable<int>(habitId),
              Variable<String>(dateKey),
            ],
          )
          .get();
      if (existing.isEmpty) {
        await _db.customStatement(
          'INSERT INTO habit_logs (habit_id, date_key, completed_at) '
          'VALUES (?, ?, ?)',
          <dynamic>[habitId, dateKey, AppDatabase.nowIso()],
        );
      } else {
        await _db.customStatement(
          'DELETE FROM habit_logs WHERE id = ?',
          <dynamic>[existing.first.readInt('id')],
        );
      }
    });
    emitChange();
  }

  Future<void> setArchived(int habitId, bool archived) async {
    await _db.customStatement(
      'UPDATE habits SET is_archived = ? WHERE id = ?',
      <dynamic>[archived ? 1 : 0, habitId],
    );
    emitChange();
  }

  Future<int> _lastInsertId() async {
    final List<QueryRow> rows = await _db
        .customSelect('SELECT last_insert_rowid() AS id')
        .get();
    return rows.first.readInt('id');
  }
}

class FinanceRepository extends ChangeEmitter {
  FinanceRepository(this._db);

  final AppDatabase _db;

  Future<List<TransactionModel>> getTransactions() async {
    final List<QueryRow> rows = await _db
        .customSelect(
          'SELECT * FROM transactions ORDER BY transacted_at DESC, id DESC',
        )
        .get();
    return rows.map(TransactionModel.fromRow).toList();
  }

  Future<List<BillModel>> getBills() async {
    final List<QueryRow> rows =
        await _db.customSelect('SELECT * FROM recurring_bills ORDER BY due_day')
            .get();
    return rows.map(BillModel.fromRow).toList();
  }

  Stream<List<TransactionModel>> watchTransactions() =>
      reactive(getTransactions);

  Stream<List<BillModel>> watchBills() => reactive(getBills);

  Future<int> addTransaction({
    required int amount,
    required String type,
    required String categoryId,
    String? note,
    DateTime? transactedAt,
  }) async {
    if (amount <= 0) {
      throw ArgumentError.value(amount, 'amount', 'مبلغ باید مثبت باشد');
    }
    if (!TransactionModel.types.contains(type)) {
      throw ArgumentError.value(type, 'type', 'نوع نامعتبر');
    }
    final String iso = (transactedAt ?? DateTime.now()).toUtc().toIso8601String();
    await _db.customStatement(
      'INSERT INTO transactions (amount, type, category_id, note, '
      'transacted_at, created_at) VALUES (?, ?, ?, ?, ?, ?)',
      <dynamic>[amount, type, categoryId, note, iso, AppDatabase.nowIso()],
    );
    emitChange();
    final List<QueryRow> rows = await _db
        .customSelect('SELECT last_insert_rowid() AS id')
        .get();
    return rows.first.readInt('id');
  }

  Future<void> addBill({
    required String title,
    required int amount,
    required int dueDay,
  }) async {
    if (dueDay < 1 || dueDay > 31) {
      throw ArgumentError.value(dueDay, 'dueDay', 'روز باید ۱..۳۱ باشد');
    }
    await _db.customStatement(
      'INSERT INTO recurring_bills (title, amount, due_day, created_at) '
      'VALUES (?, ?, ?, ?)',
      <dynamic>[title, amount, dueDay, AppDatabase.nowIso()],
    );
    emitChange();
  }

  Future<void> markBillPaid(int billId, String jalaliMonthKey) async {
    await _db.customStatement(
      'UPDATE recurring_bills SET last_paid_jalali_month = ? WHERE id = ?',
      <dynamic>[jalaliMonthKey, billId],
    );
    emitChange();
  }
}

class JournalRepository extends ChangeEmitter {
  JournalRepository(this._db);

  final AppDatabase _db;

  Future<List<JournalModel>> getAll() async {
    final List<QueryRow> rows = await _db
        .customSelect('SELECT * FROM journal_entries ORDER BY date_key DESC')
        .get();
    return rows.map(JournalModel.fromRow).toList();
  }

  Future<JournalModel?> getForDate(String dateKey) async {
    final List<QueryRow> rows = await _db
        .customSelect(
          'SELECT * FROM journal_entries WHERE date_key = ?',
          variables: <Variable<Object>>[Variable<String>(dateKey)],
        )
        .get();
    return rows.isEmpty ? null : JournalModel.fromRow(rows.first);
  }

  Stream<List<JournalModel>> watchAll() => reactive(getAll);

  Future<void> upsert({
    required String dateKey,
    required int moodScore,
    required int energyScore,
    required String tagsJson,
    required String content,
  }) async {
    if (moodScore < 1 || moodScore > 5 || energyScore < 1 || energyScore > 5) {
      throw ArgumentError.value(moodScore, 'score', 'امتیاز باید ۱..۵ باشد');
    }
    final String now = AppDatabase.nowIso();
    await _db.customStatement(
      'INSERT INTO journal_entries (date_key, mood_score, energy_score, '
      'tags_json, content, created_at, updated_at) VALUES (?, ?, ?, ?, ?, ?, ?) '
      'ON CONFLICT(date_key) DO UPDATE SET mood_score = excluded.mood_score, '
      'energy_score = excluded.energy_score, tags_json = excluded.tags_json, '
      'content = excluded.content, updated_at = excluded.updated_at',
      <dynamic>[
        dateKey,
        moodScore,
        energyScore,
        tagsJson,
        content,
        now,
        now,
      ],
    );
    emitChange();
  }
}

class SettingsRepository extends ChangeEmitter {
  SettingsRepository(this._db);

  final AppDatabase _db;

  Future<SettingsModel> get() async {
    final List<QueryRow> rows = await _db
        .customSelect('SELECT * FROM app_settings WHERE id = 1')
        .get();
    if (rows.isEmpty) {
      const SettingsModel fallback =
          SettingsModel(updatedAt: '1970-01-01T00:00:00.000Z');
      return fallback;
    }
    return SettingsModel.fromRow(rows.first);
  }

  Stream<SettingsModel> watch() => reactiveValue(get);

  Future<void> update(SettingsModel value) async {
    await _db.customStatement(
      'UPDATE app_settings SET user_name = ?, theme_mode = ?, '
      'monthly_budget = ?, biometric_lock_enabled = ?, '
      'daily_reminder_time = ?, onboarding_completed = ?, updated_at = ? '
      'WHERE id = 1',
      <dynamic>[
        value.userName,
        value.themeMode,
        value.monthlyBudget,
        value.biometricLockEnabled ? 1 : 0,
        value.dailyReminderTime,
        value.onboardingCompleted ? 1 : 0,
        value.updatedAt,
      ],
    );
    emitChange();
  }
}
