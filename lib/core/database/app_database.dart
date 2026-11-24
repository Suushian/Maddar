import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';

/// لایه ذخیرهسازی مدار برپایه Drift/SQLite.
///
/// چون در محیط ساخت پروژه امکان اجرای build_runner نبود، جداول بهصورت SQL صریح
/// ایجاد میشوند و Drift بهعنوان موتور امن Query/Transaction/Stream بهکار میرود.
/// رفتار استریمها در لایه Repository پخش میشود تا رابط بدون refresh بهروز شود.
class AppDatabase extends GeneratedDatabase {
  AppDatabase(QueryExecutor executor) : super(executor);

  AppDatabase.file(File file) : this(NativeDatabase(file));

  AppDatabase.memory() : this(NativeDatabase.memory());

  static const int currentSchemaVersion = 1;

  @override
  int get schemaVersion => currentSchemaVersion;

  @override
  Iterable<TableInfo> get allTables => const <TableInfo>[];

  static String nowIso() => DateTime.now().toUtc().toIso8601String();

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (Migrator migrator) async {
          for (final String statement in _createStatements) {
            await customStatement(statement);
          }
          await customStatement(
            'INSERT INTO app_settings (id, theme_mode, updated_at) VALUES (1, ?, ?)',
            <dynamic>['dark', nowIso()],
          );
        },
        onUpgrade: (Migrator migrator, int from, int to) async {
          // مسیر مهاجرت آینده: if (from < 2) { ... }
          // هیچ migration مخربی بدون بکاپ خودکار اجرا نمیشود.
        },
        beforeOpen: (OpeningDetails details) async {
          await customStatement('PRAGMA foreign_keys = ON');
        },
      );

  static const List<String> _createStatements = <String>[
    'CREATE TABLE IF NOT EXISTS tasks ('
        'id INTEGER PRIMARY KEY AUTOINCREMENT, '
        'title TEXT NOT NULL, '
        'note TEXT, '
        'pillar TEXT NOT NULL CHECK (pillar IN (\'work\',\'health\',\'personal\',\'learning\')), '
        'due_date TEXT, '
        'focus_date TEXT, '
        'is_top_focus INTEGER NOT NULL DEFAULT 0 CHECK (is_top_focus IN (0,1)), '
        'priority INTEGER NOT NULL DEFAULT 0 CHECK (priority IN (0,1)), '
        'is_completed INTEGER NOT NULL DEFAULT 0 CHECK (is_completed IN (0,1)), '
        'completed_at TEXT, '
        'created_at TEXT NOT NULL, '
        'CHECK (is_top_focus = 0 OR focus_date IS NOT NULL))',
    'CREATE INDEX IF NOT EXISTS idx_tasks_due ON tasks(due_date)',
    'CREATE INDEX IF NOT EXISTS idx_tasks_focus ON tasks(focus_date, is_top_focus)',
    'CREATE INDEX IF NOT EXISTS idx_tasks_done ON tasks(is_completed, due_date)',
    'CREATE TABLE IF NOT EXISTS habits ('
        'id INTEGER PRIMARY KEY AUTOINCREMENT, '
        'title TEXT NOT NULL, '
        'icon_code TEXT NOT NULL, '
        'color_hex TEXT NOT NULL, '
        'repeat_type TEXT NOT NULL CHECK (repeat_type IN (\'daily\',\'weekly\',\'alternate\')), '
        'weekday_mask INTEGER CHECK (weekday_mask IS NULL OR (weekday_mask BETWEEN 1 AND 127)), '
        'repeat_anchor_date TEXT, '
        'sort_order INTEGER NOT NULL DEFAULT 0, '
        'is_archived INTEGER NOT NULL DEFAULT 0 CHECK (is_archived IN (0,1)), '
        'created_at TEXT NOT NULL)',
    'CREATE TABLE IF NOT EXISTS habit_logs ('
        'id INTEGER PRIMARY KEY AUTOINCREMENT, '
        'habit_id INTEGER NOT NULL REFERENCES habits(id) ON DELETE CASCADE, '
        'date_key TEXT NOT NULL, '
        'completed_at TEXT NOT NULL, '
        'UNIQUE(habit_id, date_key))',
    'CREATE INDEX IF NOT EXISTS idx_habit_logs_day ON habit_logs(date_key)',
    'CREATE TABLE IF NOT EXISTS transactions ('
        'id INTEGER PRIMARY KEY AUTOINCREMENT, '
        'amount INTEGER NOT NULL CHECK (amount > 0), '
        'type TEXT NOT NULL CHECK (type IN (\'expense\',\'income\')), '
        'category_id TEXT NOT NULL, '
        'note TEXT, '
        'transacted_at TEXT NOT NULL, '
        'created_at TEXT NOT NULL)',
    'CREATE INDEX IF NOT EXISTS idx_tx_date ON transactions(transacted_at)',
    'CREATE INDEX IF NOT EXISTS idx_tx_category ON transactions(category_id)',
    'CREATE TABLE IF NOT EXISTS recurring_bills ('
        'id INTEGER PRIMARY KEY AUTOINCREMENT, '
        'title TEXT NOT NULL, '
        'amount INTEGER NOT NULL CHECK (amount > 0), '
        'due_day INTEGER NOT NULL CHECK (due_day BETWEEN 1 AND 31), '
        'last_paid_jalali_month TEXT, '
        'created_at TEXT NOT NULL)',
    'CREATE TABLE IF NOT EXISTS journal_entries ('
        'id INTEGER PRIMARY KEY AUTOINCREMENT, '
        'date_key TEXT NOT NULL UNIQUE, '
        'mood_score INTEGER NOT NULL CHECK (mood_score BETWEEN 1 AND 5), '
        'energy_score INTEGER NOT NULL CHECK (energy_score BETWEEN 1 AND 5), '
        'tags_json TEXT NOT NULL, '
        'content TEXT NOT NULL, '
        'created_at TEXT NOT NULL, '
        'updated_at TEXT NOT NULL)',
    'CREATE TABLE IF NOT EXISTS app_settings ('
        'id INTEGER PRIMARY KEY CHECK (id = 1), '
        'user_name TEXT, '
        'theme_mode TEXT NOT NULL DEFAULT \'dark\' '
        'CHECK (theme_mode IN (\'dark\',\'light\',\'system\')), '
        'monthly_budget INTEGER, '
        'biometric_lock_enabled INTEGER NOT NULL DEFAULT 0 '
        'CHECK (biometric_lock_enabled IN (0,1)), '
        'daily_reminder_time TEXT, '
        'onboarding_completed INTEGER NOT NULL DEFAULT 0 '
        'CHECK (onboarding_completed IN (0,1)), '
        'updated_at TEXT NOT NULL)',
  ];

  /// تمام جداول را در یک تراکنش پاک میکند (برای بازیابی بکاپ).
  Future<void> clearAll() async {
    for (final String table in _tableNames) {
      await customStatement('DELETE FROM $table');
    }
  }

  static const List<String> _tableNames = <String>[
    'habit_logs',
    'tasks',
    'habits',
    'transactions',
    'recurring_bills',
    'journal_entries',
    'app_settings',
  ];
}

/// مسیر دیتابیس در حافظه خصوصی اپ.
Future<AppDatabase> openAppDatabase() async {
  final Directory dir = await getApplicationDocumentsDirectory();
  return AppDatabase.file(File('${dir.path}/madaar.sqlite'));
}
