import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:madaar/core/database/app_database.dart';
import 'package:madaar/core/database/database_providers.dart';
import 'package:madaar/core/database/models.dart';
import 'package:madaar/core/database/repositories.dart';
import 'package:madaar/features/onboarding/presentation/onboarding_page.dart';

void main() {
  late AppDatabase db;
  late SettingsRepository repo;

  setUp(() async {
    db = AppDatabase.memory();
    repo = SettingsRepository(db);
    await db.customSelect('SELECT name FROM sqlite_master').get();
  });

  tearDown(() async {
    repo.dispose();
    await db.close();
  });

  testWidgets('رد کردن آنبوردینگ یکبار آن را تمام میکند', (tester) async {
    const SettingsModel settings =
        SettingsModel(updatedAt: '1970-01-01T00:00:00.000Z');
    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          settingsRepositoryProvider.overrideWith((ref) => Future<SettingsRepository>.value(repo)),
        ],
        child: MaterialApp(
          home: OnboardingPage(settings: settings, repository: repo),
        ),
      ),
    );

    await tester.tap(find.text('رد کردن'));
    await tester.pumpAndSettle();

    final SettingsModel saved = await repo.get();
    expect(saved.onboardingCompleted, true);
  });
}
