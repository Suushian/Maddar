import 'package:flutter/material.dart';
import 'package:madaar/core/theme/app_colors.dart';
import 'package:madaar/core/utils/haptics.dart';

/// داک شیشهای شناور: ۵ تب ماژول + دکمه مرکزی ثبت سریع.
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
    final Color border = AppColors.borderSubtle(context);
    final Color selected = AppColors.brand(context);
    final Color idle = AppColors.textMuted(context);

    return SafeArea(
      top: false,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.bottomCenter,
        children: <Widget>[
          Container(
            height: 72,
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            decoration: BoxDecoration(
              color: AppColors.bgElevated(context).withValues(alpha: 0.78),
              borderRadius: BorderRadius.circular(32),
              border: Border.all(color: border),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: AppColors.isDark(context)
                      ? const Color(0x66000000)
                      : const Color(0x140F172A),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(32),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Row(
                  children: <Widget>[
                    for (int i = 0; i < _labels.length; i++)
                      Expanded(
                        child: Semantics(
                          button: true,
                          selected: currentIndex == i,
                          label: _labels[i],
                          child: InkWell(
                            onTap: () {
                              if (currentIndex != i) {
                                Haptics.toggle();
                              }
                              onDestinationSelected(i);
                            },
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Icon(
                                  _icons[i],
                                  size: 22,
                                  color: currentIndex == i ? selected : idle,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _labels[i],
                                  style: TextStyle(
                                    fontFamily: 'Vazirmatn',
                                    fontSize: 10,
                                    color: currentIndex == i ? selected : idle,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 60,
            child: GestureDetector(
              onTap: () {
                Haptics.tap();
                onQuickAdd();
              },
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: selected,
                  border: Border.all(
                    color: AppColors.bgPrimary(context),
                    width: 3,
                  ),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: selected.withValues(alpha: 0.35),
                      blurRadius: 18,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
