import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:madaar/core/theme/app_colors.dart';
import 'package:madaar/core/utils/haptics.dart';

/// نوار ناوبری ثابت پایین: ۵ تب آیکوندار + دکمه ثبت سریع در سمت چپ.
/// محتوای صفحات بالای نوار قرار میگیرد و با آن همپوشانی ندارد.
class FloatingGlassDock extends StatelessWidget {
  const FloatingGlassDock({
    super.key,
    required this.currentIndex,
    required this.onDestinationSelected,
    required this.onQuickAdd,
  });

  final int currentIndex;
  final ValueChanged<int> onDestinationSelected;
  final VoidCallback onQuickAdd;

  static const List<String> _labels = <String>[
    'امروز',
    'کارها',
    'عادت‌ها',
    'جیب',
    'خلوت',
  ];

  static const List<IconData> _icons = <IconData>[
    Icons.home_rounded,
    Icons.check_circle_outline_rounded,
    Icons.local_fire_department_outlined,
    Icons.account_balance_wallet_outlined,
    Icons.nightlight_round,
  ];

  @override
  Widget build(BuildContext context) {
    final bool dark = AppColors.isDark(context);
    final Color active = AppColors.brand(context);
    final Color idle = AppColors.textMuted(context);

    return SafeArea(
      top: false,
      child: Container(
        height: 88,
        margin: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        decoration: BoxDecoration(
          color: (dark ? AppColors.ink : AppColors.paper)
              .withValues(alpha: dark ? 0.86 : 0.84),
          borderRadius: BorderRadius.circular(36),
          border: Border.all(color: AppColors.borderSubtle(context)),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: AppColors.ink.withValues(alpha: dark ? 0.32 : 0.08),
              blurRadius: 30,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(36),
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Row(
              children: <Widget>[
                for (int i = 0; i < _labels.length; i++)
                  Expanded(
                    child: _Destination(
                      icon: _icons[i],
                      label: _labels[i],
                      selected: currentIndex == i,
                      active: active,
                      idle: idle,
                      onTap: () {
                        if (currentIndex != i) {
                          Haptics.toggle();
                        }
                        onDestinationSelected(i);
                      },
                    ),
                  ),
                _QuickAddSlot(dark: dark, onTap: onQuickAdd),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Destination extends StatelessWidget {
  const _Destination({
    required this.icon,
    required this.label,
    required this.selected,
    required this.active,
    required this.idle,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final Color active;
  final Color idle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOutCubic,
              width: 64,
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selected
                    ? AppColors.stone.withValues(alpha: 0.28)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                icon,
                size: 23,
                color: selected ? active : idle,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Vazirmatn',
                fontSize: 10.5,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                color: selected ? active : idle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickAddSlot extends StatelessWidget {
  const _QuickAddSlot({required this.dark, required this.onTap});

  final bool dark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 76,
      child: Semantics(
        button: true,
        label: 'ثبت سریع',
        child: InkWell(
          onTap: () {
            Haptics.tap();
            onTap();
          },
          borderRadius: BorderRadius.circular(26),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: dark ? AppColors.paper : AppColors.ink,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.add_rounded,
                  size: 28,
                  color: dark ? AppColors.ink : AppColors.paper,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'ثبت',
                style: TextStyle(
                  fontFamily: 'Vazirmatn',
                  fontSize: 10.5,
                  color: AppColors.textMuted(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
