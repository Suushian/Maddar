import 'package:flutter/material.dart';
import 'package:madaar/core/theme/app_colors.dart';
import 'package:madaar/core/widgets/empty_state_view.dart';
import 'package:madaar/core/widgets/module_header.dart';
import 'package:madaar/core/widgets/universal_quick_add.dart';

class JournalPage extends StatelessWidget {
  const JournalPage({super.key});

  static const List<IconData> _moodIcons = <IconData>[
    Icons.sentiment_very_satisfied_rounded,
    Icons.sentiment_satisfied_rounded,
    Icons.sentiment_neutral_rounded,
    Icons.sentiment_dissatisfied_rounded,
    Icons.sentiment_very_dissatisfied_rounded,
  ];

  @override
  Widget build(BuildContext context) {
    final Color accent = AppColors.accent(context, MadaarAccent.journal);
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: <Widget>[
            ModuleHeader(
              title: 'خلوت روزانه',
              subtitle: 'حالوهوا و میکروژورنال',
              accent: accent,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  for (final IconData icon in _moodIcons)
                    IconButton(
                      tooltip: 'ثبت حس امروز',
                      onPressed: () =>
                          UniversalQuickAdd.show(context, initialTab: 2),
                      icon: Icon(icon, color: accent),
                      iconSize: 28,
                    ),
                ],
              ),
            ),
            Expanded(
              child: EmptyStateView(
                icon: Icons.nightlight_round,
                title: 'امروز هنوز ثبت نشده',
                message: 'یک لحظه کوچک را بنویس؛ لازم نیست طولانی باشد.',
                actionLabel: 'ثبت حس امروز',
                accent: accent,
                onAction: () => UniversalQuickAdd.show(context, initialTab: 2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
