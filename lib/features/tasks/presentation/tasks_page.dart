import 'package:flutter/material.dart';
import 'package:madaar/core/theme/app_colors.dart';
import 'package:madaar/core/widgets/empty_state_view.dart';
import 'package:madaar/core/widgets/module_header.dart';
import 'package:madaar/core/widgets/universal_quick_add.dart';

class TasksPage extends StatefulWidget {
  const TasksPage({super.key});

  @override
  State<TasksPage> createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage> {
  int _tab = 0;
  static const List<String> _tabs = <String>[
    'امروز',
    'صندوق ورودی',
    'برنامهریزیشده',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: <Widget>[
            ModuleHeader(
              title: 'کارها',
              subtitle: 'ساده، سریع و بدون بروکراسی',
              accent: AppColors.accent(context, MadaarAccent.tasks),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
              child: Row(
                children: <Widget>[
                  for (int i = 0; i < _tabs.length; i++)
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 3),
                        child: ChoiceChip(
                          label: Text(_tabs[i]),
                          selected: _tab == i,
                          onSelected: (_) => setState(() => _tab = i),
                          side: BorderSide(color: AppColors.borderSubtle(context)),
                          selectedColor: AppColors.accent(
                            context,
                            MadaarAccent.tasks,
                          ).withValues(alpha: 0.18),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Expanded(
              child: EmptyStateView(
                icon: Icons.check_circle_outline_rounded,
                title: 'هیچ کاری اینجا نیست',
                message: 'اولین کار را با دکمه + ثبت کن تا در این لیست ببینیش.',
                actionLabel: 'افزودن کار',
                accent: AppColors.accent(context, MadaarAccent.tasks),
                onAction: () => UniversalQuickAdd.show(context, initialTab: 0),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
