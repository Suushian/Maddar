import 'package:flutter/material.dart';
import 'package:madaar/core/theme/app_colors.dart';
import 'package:madaar/core/utils/haptics.dart';
import 'package:madaar/core/utils/jalali_helper.dart';
import 'package:madaar/core/utils/motion.dart';

/// فرم تعریف عادت با سه الگوی تکرار مطابق ADR-005.
class HabitFormSheet extends StatefulWidget {
  const HabitFormSheet({super.key, required this.onSave});

  final Future<void> Function({
    required String title,
    required String iconCode,
    required String colorHex,
    required String repeatType,
    int? weekdayMask,
    String? repeatAnchorDate,
  }) onSave;

  static Future<void> show(
    BuildContext context, {
    required Future<void> Function({
      required String title,
      required String iconCode,
      required String colorHex,
      required String repeatType,
      int? weekdayMask,
      String? repeatAnchorDate,
    }) onSave,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => HabitFormSheet(onSave: onSave),
    );
  }

  @override
  State<HabitFormSheet> createState() => _HabitFormSheetState();
}

class _HabitFormSheetState extends State<HabitFormSheet> {
  final TextEditingController _title = TextEditingController();
  String _repeatType = 'daily';
  int _weekdayMask = 127;
  int _colorIndex = 0;
  String _iconCode = 'sparkles';

  static const List<String> _repeatLabels = <String>[
    'هر روز',
    'روزهای هفته',
    'زوج/فرد',
  ];
  static const List<String> _repeatValues = <String>[
    'daily',
    'weekly',
    'alternate',
  ];
  static const List<String> _weekdayLabels = <String>[
    'ش',
    'ی',
    'د',
    'س',
    'چ',
    'پ',
    'ج',
  ];
  static const Map<String, IconData> _icons = <String, IconData>{
    'sparkles': Icons.auto_awesome_rounded,
    'book': Icons.menu_book_rounded,
    'dumbbell': Icons.fitness_center_rounded,
    'droplet': Icons.water_drop_outlined,
    'moon': Icons.nightlight_round,
  };
  static List<Color> get _colors =>
        AppColors.neutralTones.take(5).toList();

  @override
  void dispose() {
    _title.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double keyboard = MediaQuery.viewInsetsOf(context).bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: keyboard),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.bgElevated(context),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          border: Border.all(color: AppColors.borderSubtle(context)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text('عادت جدید', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            TextField(
              controller: _title,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'مثلاً: ۱۰ دقیقه مطالعه',
                filled: true,
                fillColor: AppColors.bgSurface(context),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              children: <Widget>[
                for (int i = 0; i < _repeatLabels.length; i++)
                  Motion.press(
                    context,
                    ChoiceChip(
                    label: Text(_repeatLabels[i]),
                    selected: _repeatType == _repeatValues[i],
                    onSelected: (_) => setState(() => _repeatType = _repeatValues[i]),
                  )),
              ],
            ),
            if (_repeatType == 'weekly') ...<Widget>[
              const SizedBox(height: 12),
              Wrap(
                spacing: 6,
                children: <Widget>[
                  for (int i = 0; i < 7; i++)
                    Motion.press(
                      context,
                      FilterChip(
                      label: Text(_weekdayLabels[i]),
                      selected: (_weekdayMask & (1 << i)) != 0,
                      onSelected: (_) => setState(
                        () => _weekdayMask ^= 1 << i,
                      ),
                    )),
                ],
              ),
            ],
            const SizedBox(height: 16),
            Wrap(
              spacing: 10,
              children: <Widget>[
                for (int i = 0; i < _colors.length; i++)
                  GestureDetector(
                    onTap: () => setState(() => _colorIndex = i),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: _colors[i],
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: _colorIndex == i
                              ? AppColors.textPrimary(context)
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 10,
              children: <Widget>[
                for (final MapEntry<String, IconData> icon in _icons.entries)
                  Motion.press(
                    context,
                    IconButton(
                    tooltip: icon.key,
                    onPressed: () => setState(() => _iconCode = icon.key),
                    icon: Icon(
                      icon.value,
                      color: _iconCode == icon.key
                          ? _colors[_colorIndex]
                          : AppColors.textMuted(context),
                    ),
                  )),
              ],
            ),
            const SizedBox(height: 24),
            Motion.press(
              context,
              FilledButton(
              onPressed: () async {
                final String title = _title.text.trim();
                if (title.isEmpty) {
                  return;
                }
                await Haptics.success();
                await widget.onSave(
                  title: title,
                  iconCode: _iconCode,
                  colorHex:
                      '#${_colors[_colorIndex].value.toRadixString(16).substring(2).toUpperCase()}',
                  repeatType: _repeatType,
                  weekdayMask: _repeatType == 'weekly' ? _weekdayMask : null,
                  repeatAnchorDate: _repeatType == 'alternate'
                      ? JalaliHelper.dateKey(DateTime.now())
                      : null,
                );
                if (context.mounted) {
                  Navigator.of(context).pop();
                }
              },
              child: const Text('ذخیره عادت'),
            )),
          ],
        ),
      ),
    );
  }
}
