import 'package:flutter/material.dart';
import 'package:madaar/core/theme/app_colors.dart';
import 'package:madaar/core/widgets/empty_state_view.dart';
import 'package:madaar/core/widgets/module_header.dart';
import 'package:madaar/core/widgets/universal_quick_add.dart';

class HabitsPage extends StatelessWidget {
  const HabitsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final Color accent = AppColors.accent(context, MadaarAccent.habits);
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: <Widget>[
            ModuleHeader(
              title: 'ریتم و عادت‌ها',
              subtitle: 'زنجیرهها و نقشه پیوستگی',
              accent: accent,
            ),
            Expanded(
              child: EmptyStateView(
                icon: Icons.local_fire_department_outlined,
                title: 'هنوز عادتی تعریف نشده',
                message: 'یک عادت کوچک انتخاب کن؛ زنجیرهاش به مرور ساخته میشود.',
                actionLabel: 'تعریف عادت',
                accent: accent,
                onAction: () => UniversalQuickAdd.show(context, initialTab: 3),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
