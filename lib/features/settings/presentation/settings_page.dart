import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:madaar/core/database/backup_service.dart';
import 'package:madaar/core/database/database_providers.dart';
import 'package:madaar/core/database/models.dart';
import 'package:madaar/core/database/repositories.dart';
import 'package:madaar/core/state/app_providers.dart';
import 'package:madaar/core/utils/currency_formatter.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeMode mode = ref.watch(themeModeProvider);
    final AsyncValue<SettingsRepository> repoAsync =
        ref.watch(settingsRepositoryProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('تنظیمات')),
      body: repoAsync.when(
        data: (SettingsRepository repo) => StreamBuilder<SettingsModel>(
          stream: repo.watch(),
          builder: (
            BuildContext context,
            AsyncSnapshot<SettingsModel> snapshot,
          ) {
            final SettingsModel settings = snapshot.data ??
                const SettingsModel(updatedAt: '1970-01-01T00:00:00.000Z');
            return ListView(
              children: <Widget>[
                ListTile(
                  leading: const Icon(Icons.dark_mode_outlined),
                  title: const Text('تم'),
                  subtitle: const Text('تاریک بهعنوان پیشفرض'),
                  trailing: DropdownButton<ThemeMode>(
                    value: mode,
                    onChanged: (ThemeMode? value) {
                      if (value != null) {
                        ref.read(themeModeProvider.notifier).state = value;
                      }
                    },
                    items: const <DropdownMenuItem<ThemeMode>>[
                      DropdownMenuItem(
                        value: ThemeMode.dark,
                        child: Text('تاریک'),
                      ),
                      DropdownMenuItem(
                        value: ThemeMode.light,
                        child: Text('روشن'),
                      ),
                      DropdownMenuItem(
                        value: ThemeMode.system,
                        child: Text('سیستم'),
                      ),
                    ],
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.savings_outlined),
                  title: const Text('بودجه ماهانه'),
                  subtitle: Text(
                    settings.monthlyBudget == null
                        ? 'تنظیم نشده'
                        : CurrencyFormatter.format(settings.monthlyBudget!),
                  ),
                  onTap: () => _editBudget(context, repo, settings),
                ),
                ListTile(
                  leading: const Icon(Icons.notifications_none_rounded),
                  title: const Text('یادآور شبانه'),
                  subtitle: Text(
                    settings.dailyReminderTime ?? 'تنظیم نشده',
                  ),
                  onTap: () => _editReminder(context, repo, settings),
                ),
                SwitchListTile(
                  secondary: const Icon(Icons.fingerprint_outlined),
                  title: const Text('قفل بیومتریک'),
                  subtitle: const Text('اختیاری و خاموش پیشفرض'),
                  value: settings.biometricLockEnabled,
                  onChanged: (bool value) async {
                    await repo.update(
                      settings.copyWith(biometricLockEnabled: value),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.backup_outlined),
                  title: const Text('بکاپ و بازیابی'),
                  subtitle: const Text(
                    'خروجی JSON نسخهدار — کپی و جایگذاری',
                  ),
                  onTap: () => _backupSheet(context, ref),
                ),
                const Divider(),
                const ListTile(
                  title: Text('مدار'),
                  subtitle: Text('نسخه ۰.۱.۰ — Personal Life OS'),
                ),
              ],
            );
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (Object error, StackTrace stack) => Center(
          child: Text('دسترسی به تنظیمات ممکن نشد: $error'),
        ),
      ),
    );
  }

  Future<void> _editBudget(
    BuildContext context,
    SettingsRepository repo,
    SettingsModel settings,
  ) async {
    final TextEditingController controller = TextEditingController(
      text: settings.monthlyBudget?.toString() ?? '',
    );
    await showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: const Text('بودجه ماهانه (تومان)'),
        content: TextField(
          controller: controller,
          autofocus: true,
          keyboardType: TextInputType.number,
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('لغو'),
          ),
          FilledButton(
            onPressed: () async {
              final int? value = int.tryParse(controller.text.trim());
              if (value == null || value <= 0) {
                return;
              }
              await repo.update(settings.copyWith(monthlyBudget: value));
              if (dialogContext.mounted) {
                Navigator.of(dialogContext).pop();
              }
            },
            child: const Text('ذخیره'),
          ),
        ],
      ),
    );
    controller.dispose();
  }

  Future<void> _editReminder(
    BuildContext context,
    SettingsRepository repo,
    SettingsModel settings,
  ) async {
    final TextEditingController controller = TextEditingController(
      text: settings.dailyReminderTime ?? '21:00',
    );
    await showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: const Text('ساعت یادآور شبانه'),
        content: TextField(
          controller: controller,
          autofocus: true,
          keyboardType: TextInputType.datetime,
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('لغو'),
          ),
          FilledButton(
            onPressed: () async {
              final RegExp pattern = RegExp(r'^\d{2}:\d{2}$');
              final String value = controller.text.trim();
              if (!pattern.hasMatch(value)) {
                return;
              }
              await repo.update(settings.copyWith(dailyReminderTime: value));
              if (dialogContext.mounted) {
                Navigator.of(dialogContext).pop();
              }
            },
            child: const Text('ذخیره'),
          ),
        ],
      ),
    );
    controller.dispose();
  }

  void _backupSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext sheetContext) => Consumer(
        builder: (BuildContext context, WidgetRef ref, Widget? child) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.viewInsetsOf(context).bottom,
          ),
          child: ref.watch(backupServiceProvider).when(
                data: (BackupService service) => _BackupSheet(service: service),
                loading: () => const SizedBox(
                  height: 120,
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (Object error, StackTrace stack) => SizedBox(
                  height: 120,
                  child: Center(child: Text('خطا: $error')),
                ),
              ),
        ),
      ),
    );
  }
}

class _BackupSheet extends StatefulWidget {
  const _BackupSheet({required this.service});

  final BackupService service;

  @override
  State<_BackupSheet> createState() => _BackupSheetState();
}

class _BackupSheetState extends State<_BackupSheet> {
  final TextEditingController _input = TextEditingController();
  String _message = '';

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(
            'بکاپ و بازیابی',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          FilledButton.tonal(
            onPressed: () async {
              final String json = await widget.service.exportToJson();
              await Clipboard.setData(ClipboardData(text: json));
              setState(() => _message = 'بکاپ در کلیپبورد کپی شد');
            },
            child: const Text('کپی بکاپ JSON'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _input,
            maxLines: 4,
            decoration: const InputDecoration(
              hintText: 'محتوای بکاپ را اینجا بچسبانید',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: () async {
              try {
                await widget.service.importFromJson(_input.text.trim());
                setState(() => _message = 'بازیابی با موفقیت انجام شد');
              } catch (error) {
                setState(() => _message = 'بازیابی ناموفق: $error');
              }
            },
            child: const Text('بازیابی'),
          ),
          if (_message.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(_message),
            ),
        ],
      ),
    );
  }
}
