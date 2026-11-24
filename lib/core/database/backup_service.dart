import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:madaar/core/database/app_database.dart';
import 'package:madaar/core/database/models.dart';

/// JSON بکاپ نسخهدار مطابق ADR-011. بازیابی درون تراکنش و با اسنپشات انجام میشود.
class BackupService {
  BackupService(this._db, this._directoryProvider);

  static const String format = 'madaar-backup';
  static const int schemaVersion = 1;

  final AppDatabase _db;
  final Future<Directory> Function() _directoryProvider;

  Future<Map<String, dynamic>> exportData() async {
    return <String, dynamic>{
      'format': format,
      'schema_version': schemaVersion,
      'exported_at': AppDatabase.nowIso(),
      'data': <String, dynamic>{
        'tasks': (await _select('tasks')).map(TaskModel.fromRow).map((e) => e.toJson()).toList(),
        'habits': (await _select('habits')).map(HabitModel.fromRow).map((e) => e.toJson()).toList(),
        'habit_logs': (await _select('habit_logs')).map(HabitLogModel.fromRow).map((e) => e.toJson()).toList(),
        'transactions': (await _select('transactions')).map(TransactionModel.fromRow).map((e) => e.toJson()).toList(),
        'recurring_bills': (await _select('recurring_bills')).map(BillModel.fromRow).map((e) => e.toJson()).toList(),
        'journal_entries': (await _select('journal_entries')).map(JournalModel.fromRow).map((e) => e.toJson()).toList(),
        'app_settings': (await _select('app_settings')).map(SettingsModel.fromRow).map((e) => e.toJson()).toList(),
      },
    };
  }

  Future<String> exportToJson() async => jsonEncode(await exportData());

  Future<void> importData(Map<String, dynamic> payload) async {
    final String? payloadFormat = payload['format'] as String?;
    if (payloadFormat != format) {
      throw const FormatException('فرمت بکاپ معتبر نیست');
    }
    final int? version = (payload['schema_version'] as num?)?.toInt();
    if (version == null || version < 1 || version > schemaVersion) {
      throw const FormatException('نسخه اسکیمای بکاپ پشتیبانی نمیشود');
    }
    final Map<String, dynamic>? data = payload['data'] as Map<String, dynamic>?;
    if (data == null) {
      throw const FormatException('بخش data در بکاپ وجود ندارد');
    }

    await _writeSnapshot();

    await _db.transaction(() async {
      await _db.clearAll();
      await _insertRows('tasks', data, (json) => TaskModel.fromJson(json).toJson());
      await _insertRows('habits', data, (json) => HabitModel.fromJson(json).toJson());
      await _insertRows('habit_logs', data, (json) => HabitLogModel.fromJson(json).toJson());
      await _insertRows('transactions', data, (json) => TransactionModel.fromJson(json).toJson());
      await _insertRows('recurring_bills', data, (json) => BillModel.fromJson(json).toJson());
      await _insertRows('journal_entries', data, (json) => JournalModel.fromJson(json).toJson());
      await _insertRows('app_settings', data, (json) => SettingsModel.fromJson(json).toJson());
    });
  }

  Future<void> importFromJson(String source) async {
    final Object? decoded = jsonDecode(source);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('محتوای بکاپ یک شیء JSON نیست');
    }
    await importData(decoded);
  }

  Future<void> _insertRows(
    String key,
    Map<String, dynamic> data,
    Map<String, dynamic> Function(Map<String, dynamic>) convert,
  ) async {
    final List<dynamic>? rows = data[key] as List<dynamic>?;
    if (rows == null) {
      throw FormatException('کلید $key در بکاپ موجود نیست');
    }
    for (final dynamic entry in rows) {
      if (entry is! Map<String, dynamic>) {
        throw FormatException('ردیف $key نامعتبر است');
      }
      final Map<String, dynamic> json = convert(entry);
      final List<String> keys = json.keys.toList();
      final String columns = keys.join(', ');
      final String placeholders = List<String>.filled(keys.length, '?').join(', ');
      await _db.customStatement(
        'INSERT INTO $key ($columns) VALUES ($placeholders)',
        keys.map((String name) => json[name]).toList(),
      );
    }
  }

  Future<List<QueryRow>> _select(String table) =>
      _db.customSelect('SELECT * FROM $table ORDER BY id').get();

  Future<void> _writeSnapshot() async {
    final Directory dir = await _directoryProvider();
    final String stamp = DateTime.now()
        .toIso8601String()
        .replaceAll(':', '-')
        .replaceAll('.', '-');
    final File file = File('${dir.path}/pre-import-$stamp.json');
    await file.writeAsString(await exportToJson());
  }
}
