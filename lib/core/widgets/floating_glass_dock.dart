import 'package:flutter/material.dart';
import 'package:madaar/core/theme/app_colors.dart';
import 'package:madaar/core/utils/haptics.dart';
import 'package:madaar/core/utils/motion.dart';

/// نوار ناوبری ثابت و مسطح پایین: پنج تب آیکوندار + دکمه ثبت.
/// سبک Notion/Obsidian: پسزمینه تخت، خط جداکننده بالا، بدون شیشه و سایه.
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
    Icons.home_outlined,
    Icons.check_circle_outline,
    Icons.local_fire_department_outlined,
    Icons.account_balance_wallet_outlined,
    Icons.nightlight_outlined,
  ];

  @override
  Widget build(BuildContext context) {
    final Color active = AppColors.textPrimary(context);
    final Color idle = AppColors.textMuted(context);
    final bool dark = AppColors.isDark(context);

    return Container(
      decoration: BoxDecoration(
        color: dark ? AppColors.ink : AppColors.paper,
        border: Border(
          top: BorderSide(color: AppColors.borderSubtle(context), width: 1),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            children: <Widget>[
              for (int i = 0; i < _labels.length; i++)
                Expanded(
                  child: Motion.entrance(
                    context,
                    _Destination(
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
                    i,
                    id: 'dock',
                  ),
                ),
              SizedBox(
                width: 64,
                child: Motion.entrance(
                  context,
                  _QuickAddSlot(dark: dark, onTap: onQuickAdd),
                  5,
                  id: 'dock',
                ),
              ),
            ],
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
      child: Motion.press(
        context,
        InkWell(
          onTap: onTap,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              AnimatedScale(
                scale: selected ? 1.12 : 1,
                duration: Motion.fast,
                curve: Curves.easeOutBack,
                child: Icon(icon, size: 21, color: selected ? active : idle),
              ),
              const SizedBox(height: 3),
              AnimatedDefaultTextStyle(
                duration: Motion.fast,
                curve: Curves.easeOutCubic,
                style: TextStyle(
                  fontFamily: 'Vazirmatn',
                  fontSize: 10,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                  color: selected ? active : idle,
                ),
                child: Text(label),
              ),
              AnimatedContainer(
                duration: Motion.micro,
                curve: Curves.easeOutCubic,
                width: selected ? 18 : 0,
                height: selected ? 2.5 : 0,
                margin: const EdgeInsets.only(top: 2),
                decoration: BoxDecoration(
                  color: active,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ],
          ),
        ),
        minScale: 0.92,
      ),
    );
  }
}

class _QuickAddSlot extends StatefulWidget {
  const _QuickAddSlot({required this.dark, required this.onTap});

  final bool dark;
  final VoidCallback onTap;

  @override
  State<_QuickAddSlot> createState() => _QuickAddSlotState();
}

class _QuickAddSlotState extends State<_QuickAddSlot> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed != value && mounted) {
      setState(() => _pressed = value);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'ثبت سریع',
      child: Listener(
        behavior: HitTestBehavior.deferToChild,
        onPointerDown: (_) => _setPressed(true),
        onPointerUp: (_) => _setPressed(false),
        onPointerCancel: (_) => _setPressed(false),
        child: AnimatedScale(
          scale: _pressed ? 0.86 : 1,
          duration: _pressed ? Motion.micro : Motion.base,
          curve: Curves.easeOutCubic,
          child: AnimatedRotation(
            turns: _pressed ? 0.125 : 0,
            duration: Motion.fast,
            curve: Curves.easeOutCubic,
            child: InkWell(
              onTap: () {
                Haptics.tap();
                widget.onTap();
              },
              child: Center(
                child: Motion.pulse(
                  context,
                  Icon(
                    Icons.add_rounded,
                    size: 26,
                    color: widget.dark ? AppColors.paper : AppColors.ink,
                  ),
                  id: 'quick-add',
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
