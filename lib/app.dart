import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:madaar/core/database/database_providers.dart';
import 'package:madaar/core/database/models.dart';
import 'package:madaar/core/database/repositories.dart';
import 'package:madaar/core/notifications/notification_providers.dart';
import 'package:madaar/core/router/app_router.dart';
import 'package:madaar/core/security/biometric_gate.dart';
import 'package:madaar/core/state/app_providers.dart';
import 'package:madaar/core/theme/app_theme.dart';
import 'package:madaar/features/onboarding/presentation/onboarding_page.dart';

class MadaarApp extends ConsumerWidget {
  const MadaarApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeMode mode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: 'مدار',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: mode,
      locale: const Locale('fa', 'IR'),
      supportedLocales: const <Locale>[Locale('fa', 'IR')],
      localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      routerConfig: appRouter,
      builder: (BuildContext context, Widget? child) {
        final Widget root = Directionality(
          textDirection: TextDirection.rtl,
          child: child ?? const SizedBox.shrink(),
        );
        return _SettingsBootstrap(
          child: BiometricGate(
            child: _OnboardingGate(child: root),
          ),
        );
      },
    );
  }
}

/// تم ذخیرهشده را بارگذاری میکند و یادآورها را با تنظیمات هماهنگ نگه میدارد.
class _SettingsBootstrap extends ConsumerStatefulWidget {
  const _SettingsBootstrap({required this.child});

  final Widget child;

  @override
  ConsumerState<_SettingsBootstrap> createState() =>
      _SettingsBootstrapState();
}

class _SettingsBootstrapState extends ConsumerState<_SettingsBootstrap> {
  StreamSubscription<SettingsModel>? _subscription;

  @override
  void initState() {
    super.initState();
    _start();
  }

  Future<void> _start() async {
    final SettingsRepository repo = await ref.read(settingsRepositoryProvider.future);
    await ref.read(notificationServiceProvider).initialize();
    if (!mounted) {
      return;
    }
    _subscription = repo.watch().listen((SettingsModel settings) {
      final ThemeMode saved = switch (settings.themeMode) {
        'light' => ThemeMode.light,
        'system' => ThemeMode.system,
        _ => ThemeMode.dark,
      };
      if (ref.read(themeModeProvider) != saved) {
        ref.read(themeModeProvider.notifier).state = saved;
      }
      unawaited(ref.read(notificationServiceProvider).syncSchedule(settings));
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

class _OnboardingGate extends ConsumerWidget {
  const _OnboardingGate({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<SettingsRepository> repoAsync =
        ref.watch(settingsRepositoryProvider);
    return repoAsync.when(
      data: (SettingsRepository repo) => StreamBuilder<SettingsModel>(
        stream: repo.watch(),
        builder: (
          BuildContext context,
          AsyncSnapshot<SettingsModel> snapshot,
        ) {
          final SettingsModel? settings = snapshot.data;
          if (settings == null || settings.onboardingCompleted) {
            return child;
          }
          return OnboardingPage(settings: settings, repository: repo);
        },
      ),
      loading: () => child,
      error: (Object error, StackTrace stack) => child,
    );
  }
}
