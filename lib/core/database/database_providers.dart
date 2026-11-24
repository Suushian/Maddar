import 'dart:async';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:madaar/core/database/app_database.dart';
import 'package:madaar/core/database/backup_service.dart';
import 'package:madaar/core/database/repositories.dart';
import 'package:path_provider/path_provider.dart';

final FutureProvider<AppDatabase> appDatabaseProvider =
    FutureProvider<AppDatabase>((ref) async {
  final AppDatabase db = await openAppDatabase();
  ref.onDispose(() {
    unawaited(db.close());
  });
  return db;
});

final FutureProvider<TasksRepository> tasksRepositoryProvider =
    FutureProvider<TasksRepository>((ref) async {
  final AppDatabase db = await ref.watch(appDatabaseProvider.future);
  final TasksRepository repo = TasksRepository(db);
  ref.onDispose(repo.dispose);
  return repo;
});

final FutureProvider<HabitsRepository> habitsRepositoryProvider =
    FutureProvider<HabitsRepository>((ref) async {
  final AppDatabase db = await ref.watch(appDatabaseProvider.future);
  final HabitsRepository repo = HabitsRepository(db);
  ref.onDispose(repo.dispose);
  return repo;
});

final FutureProvider<FinanceRepository> financeRepositoryProvider =
    FutureProvider<FinanceRepository>((ref) async {
  final AppDatabase db = await ref.watch(appDatabaseProvider.future);
  final FinanceRepository repo = FinanceRepository(db);
  ref.onDispose(repo.dispose);
  return repo;
});

final FutureProvider<JournalRepository> journalRepositoryProvider =
    FutureProvider<JournalRepository>((ref) async {
  final AppDatabase db = await ref.watch(appDatabaseProvider.future);
  final JournalRepository repo = JournalRepository(db);
  ref.onDispose(repo.dispose);
  return repo;
});

final FutureProvider<SettingsRepository> settingsRepositoryProvider =
    FutureProvider<SettingsRepository>((ref) async {
  final AppDatabase db = await ref.watch(appDatabaseProvider.future);
  final SettingsRepository repo = SettingsRepository(db);
  ref.onDispose(repo.dispose);
  return repo;
});

final FutureProvider<BackupService> backupServiceProvider =
    FutureProvider<BackupService>((ref) async {
  final AppDatabase db = await ref.watch(appDatabaseProvider.future);
  final Directory dir = await getApplicationDocumentsDirectory();
  return BackupService(db, () async => dir);
});
