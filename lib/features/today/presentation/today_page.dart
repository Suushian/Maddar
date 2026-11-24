import 'package:flutter/material.dart';
import 'package:madaar/core/theme/app_colors.dart';
import 'package:madaar/core/utils/currency_formatter.dart';
import 'package:madaar/core/utils/jalali_helper.dart';
import 'package:madaar/core/widgets/bento_card.dart';
import 'package:madaar/core/widgets/module_header.dart';
import 'package:madaar/core/widgets/universal_quick_add.dart';

/// مرکز فرماندهی امروز. در فاز ۱ ساختار کارتها و تاریخ واقعی نمایش داده میشود؛
/// استریمهای Drift در فاز ۴ به کارتها متصل میشوند.
class TodayPage extends StatelessWidget {
  const TodayPage({super.key});

  @override
  Widget build(BuildContext context) {
    final DateTime now = DateTime.now();
    final Color tasksColor = AppColors.accent(context, MadaarAccent.tasks);
    final Color habitsColor = AppColors.accent(context, MadaarAccent.habits);
    final Color journalColor = AppColors.accent(context, MadaarAccent.journal);

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: <Widget>[
            SliverToBoxAdapter(
              child: ModuleHeader(
                title: JalaliHelper.greeting(now),
                subtitle: JalaliHelper.fullDate(now),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: <Widget>[
                    _ProgressRing(percent: 0),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'پیشرفت امروز',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'کارها و عادتهای امروز اینجا جمع میشوند.',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 20)),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: BentoCard(
                  accent: tasksColor,
                  onTap: () => UniversalQuickAdd.show(context, initialTab: 0),
                  child: Row(
                    children: <Widget>[
                      Icon(Icons.auto_awesome_rounded, color: tasksColor),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              '۳ تمرکز طلایی امروز',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'هنوز کاری پین نشده است',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.add_rounded, size: 20),
                    ],
                  ),
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 12)),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: BentoCard(
                  accent: habitsColor,
                  onTap: () => UniversalQuickAdd.show(context, initialTab: 3),
                  child: Row(
                    children: <Widget>[
                      Icon(Icons.local_fire_department_rounded, color: habitsColor),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              'عادتهای امروز',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'یک لمس تا تیک بخورند',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_left_rounded),
                    ],
                  ),
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 12)),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: BentoCard(
                        height: 132,
                        onTap: () =>
                            UniversalQuickAdd.show(context, initialTab: 1),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              'جیب امروز',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const Spacer(),
                            Text(
                              CurrencyFormatter.format(0),
                              style: Theme.of(context).textTheme.headlineMedium,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'بودجه تنظیم نشده',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: BentoCard(
                        height: 132,
                        accent: journalColor,
                        onTap: () =>
                            UniversalQuickAdd.show(context, initialTab: 2),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              'حالوهوای امروز',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const Spacer(),
                            Icon(Icons.self_improvement_rounded,
                                color: journalColor, size: 30),
                            const SizedBox(height: 4),
                            Text(
                              'ثبت نشده است',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 28)),
          ],
        ),
      ),
    );
  }
}

class _ProgressRing extends StatelessWidget {
  const _ProgressRing({required this.percent});

  final int percent;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 64,
      height: 64,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          CircularProgressIndicator(
            value: 0.0,
            strokeWidth: 6,
            backgroundColor: AppColors.borderSubtle(context),
            color: AppColors.brand(context),
          ),
          Text(
            '${JalaliHelper.faDigits(percent)}٪',
            style: Theme.of(context).textTheme.labelMedium,
          ),
        ],
      ),
    );
  }
}
