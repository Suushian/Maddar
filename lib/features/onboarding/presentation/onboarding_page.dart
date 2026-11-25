import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:madaar/core/database/models.dart';
import 'package:madaar/core/database/repositories.dart';
import 'package:madaar/core/notifications/notification_providers.dart';
import 'package:madaar/core/state/app_providers.dart';
import 'package:madaar/core/theme/app_colors.dart';
import 'package:madaar/core/utils/currency_formatter.dart';
import 'package:madaar/core/utils/haptics.dart';
import 'package:madaar/core/utils/motion.dart';

/// آنبوردینگ ۳۰ ثانیهای: نام، بودجه، تم و یادآور.
class OnboardingPage extends ConsumerStatefulWidget {
  const OnboardingPage({
    super.key,
    required this.settings,
    required this.repository,
  });

  final SettingsModel settings;
  final SettingsRepository repository;

  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends ConsumerState<OnboardingPage> {
  final TextEditingController _name = TextEditingController();
  final TextEditingController _budget = TextEditingController();
  final TextEditingController _reminder = TextEditingController(text: '21:00');
  int _step = 0;
  ThemeMode _theme = ThemeMode.dark;

  static const List<String> _titles = <String>[
    'به مدار خوش آمدید',
    'بودجه ماهانه',
    'تم و یادآور',
  ];
  static const List<String> _descriptions = <String>[
    'یک نام کوتاه انتخاب کنید تا خانه شخصیتر شود. بقیه چیزها پیشفرضاند.',
    'یک عدد تقریبی کافی است؛ بعدها در تنظیمات قابل تغییر است.',
    'تم تاریک پیشفرض است و یادآور شبانه میتواند خاموش یا روشن باشد.',
  ];

  @override
  void dispose() {
    _name.dispose();
    _budget.dispose();
    _reminder.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color brand = AppColors.brand(context);
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  onPressed: () => unawaited(_finish(saveValues: false)),
                  child: const Text('رد کردن'),
                ),
              ),
              const SizedBox(height: 24),
              Motion.entrance(
                context,
                Icon(Icons.auto_awesome_rounded, size: 56, color: brand),
                0,
              ),
              const SizedBox(height: 20),
              Text(
                _titles[_step],
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                _descriptions[_step],
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              Expanded(
                child: AnimatedSwitcher(
                  duration: Motion.reduced(context)
                      ? Duration.zero
                      : const Duration(milliseconds: 220),
                  child: _stepContent(context),
                ),
              ),
              Row(
                children: <Widget>[
                  for (int i = 0; i < 3; i++)
                    Expanded(
                      child: Container(
                        height: 5,
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        decoration: BoxDecoration(
                          color: i <= _step ? brand : AppColors.borderSubtle(context),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 24),
              FilledButton(
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(54),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {
                  if (_step < 2) {
                    Haptics.tap();
                    setState(() => _step += 1);
                  } else {
                    unawaited(_finish(saveValues: true));
                  }
                },
                child: Text(_step == 2 ? 'ورود به مدار' : 'ادامه'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _stepContent(BuildContext context) {
    if (_step == 0) {
      return Motion.entrance(
        context,
        TextField(
          key: const ValueKey<int>(0),
          controller: _name,
          autofocus: true,
          textAlign: TextAlign.center,
          decoration: const InputDecoration(
            hintText: 'نام تو',
            border: OutlineInputBorder(),
          ),
        ),
        0,
      );
    }
    if (_step == 1) {
      return Motion.entrance(
        context,
        TextField(
          key: const ValueKey<int>(1),
          controller: _budget,
          autofocus: true,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          decoration: const InputDecoration(
            hintText: 'مثلاً ۲,۰۰۰,۰۰۰ تومان',
            border: OutlineInputBorder(),
          ),
        ),
        0,
      );
    }
    return Motion.entrance(
      context,
      SingleChildScrollView(
        key: const ValueKey<int>(2),
        child: Column(
          children: <Widget>[
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 10,
              children: <Widget>[
                for (final ThemeMode mode in ThemeMode.values)
                  ChoiceChip(
                    label: Text(_themeLabel(mode)),
                    selected: _theme == mode,
                    onSelected: (_) => setState(() => _theme = mode),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _reminder,
              textAlign: TextAlign.center,
              keyboardType: TextInputType.datetime,
              decoration: const InputDecoration(
                labelText: 'ساعت یادآور شبانه (مثلاً 21:00)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'اعلانها فقط روی دستگاه شما نمایش داده میشوند.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
      0,
    );
  }

  static String _themeLabel(ThemeMode mode) => switch (mode) {
        ThemeMode.dark => 'تاریک',
        ThemeMode.light => 'روشن',
        ThemeMode.system => 'سیستم',
      };

  Future<void> _finish({required bool saveValues}) async {
    final SettingsModel current = widget.settings;
    final int? budget = saveValues
        ? CurrencyFormatter.parse(_budget.text)
        : null;
    final String time =
        saveValues && RegExp(r'^\d{2}:\d{2}$').hasMatch(_reminder.text)
            ? _reminder.text.trim()
            : (current.dailyReminderTime ?? '21:00');
    final String themeMode = saveValues ? _theme.name : current.themeMode;

    await widget.repository.update(
      current.copyWith(
        userName: saveValues && _name.text.trim().isNotEmpty
            ? _name.text.trim()
            : current.userName,
        monthlyBudget: budget != null && budget > 0 ? budget : current.monthlyBudget,
        dailyReminderTime: time,
        themeMode: themeMode,
        onboardingCompleted: true,
      ),
    );
    // Haptics are cosmetic; a missing platform channel must never block onboarding.
    try {
      await Haptics.success();
    } on Object {
      // ignore: avoid_catches_without_on_clauses
    }
    ref.read(themeModeProvider.notifier).state = switch (themeMode) {
      'dark' => ThemeMode.dark,
      'light' => ThemeMode.light,
      _ => ThemeMode.system,
    };

    final bool granted = await ref.read(notificationServiceProvider).requestPermission();
    if (granted) {
      await ref
          .read(notificationServiceProvider)
          .syncSchedule(await widget.repository.get());
    }
  }

}
