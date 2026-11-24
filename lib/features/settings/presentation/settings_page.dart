import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:madaar/core/state/app_providers.dart';
import 'package:madaar/core/utils/currency_formatter.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeMode mode = ref.watch(themeModeProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('تنظیمات')),
      body: ListView(
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
          const ListTile(
            leading: Icon(Icons.savings_outlined),
            title: Text('بودجه ماهانه'),
            subtitle: Text('تنظیم نشده'),
          ),
          const ListTile(
            leading: Icon(Icons.notifications_none_rounded),
            title: Text('یادآور شبانه'),
            subtitle: Text('خاموش'),
          ),
          const ListTile(
            leading: Icon(Icons.fingerprint_outlined),
            title: Text('قفل بیومتریک'),
            subtitle: Text('اختیاری و خاموش پیشفرض'),
          ),
          ListTile(
            leading: const Icon(Icons.backup_outlined),
            title: const Text('بکاپ و بازیابی'),
            subtitle: Text(
              'خروجی JSON نسخهدار — ${CurrencyFormatter.digits(7)} جدول',
            ),
          ),
          const Divider(),
          const ListTile(
            title: Text('مدار'),
            subtitle: Text('نسخه ۰.۱.۰ — Personal Life OS'),
          ),
        ],
      ),
    );
  }
}
