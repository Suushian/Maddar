import 'package:flutter/material.dart';
import 'package:madaar/core/theme/app_colors.dart';
import 'package:madaar/core/utils/currency_formatter.dart';
import 'package:madaar/core/widgets/bento_card.dart';
import 'package:madaar/core/widgets/empty_state_view.dart';
import 'package:madaar/core/widgets/module_header.dart';
import 'package:madaar/core/widgets/universal_quick_add.dart';

class FinancePage extends StatelessWidget {
  const FinancePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: <Widget>[
            ModuleHeader(
              title: 'جیب هوشمند',
              subtitle: 'ثبت هزینه در سه ثانیه',
              accent: AppColors.accent(context, MadaarAccent.income),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: BentoCard(
                      onTap: () => UniversalQuickAdd.show(context, initialTab: 1),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'خرج امروز',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            CurrencyFormatter.format(0),
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: BentoCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'بودجه ماه',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'تنظیم نشده',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: EmptyStateView(
                icon: Icons.account_balance_wallet_outlined,
                title: 'تراکنشهای این ماه خالیاند',
                message: 'با کیپد اختیاری، هزینهای را در سه لمس ثبت کن.',
                actionLabel: 'ثبت تراکنش',
                accent: AppColors.accent(context, MadaarAccent.income),
                onAction: () => UniversalQuickAdd.show(context, initialTab: 1),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
