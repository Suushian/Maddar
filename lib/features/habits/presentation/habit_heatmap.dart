import 'package:flutter/material.dart';
import 'package:madaar/core/database/models.dart';
import 'package:madaar/core/theme/app_colors.dart';
import 'package:madaar/core/utils/haptics.dart';
import 'package:madaar/core/utils/jalali_helper.dart';
import 'package:madaar/core/utils/motion.dart';

/// ماتریس پیوستگی ۳۰/۹۰ روزه با مربعهای گرد 6px و طیف رنگ عادت.
class HabitHeatmap extends StatelessWidget {
  const HabitHeatmap({
    super.key,
    required this.habit,
    required this.completedKeys,
    required this.days,
    required this.onDayTap,
  });

  final HabitModel habit;
  final Set<String> completedKeys;
  final int days;
  final ValueChanged<String> onDayTap;

  @override
  Widget build(BuildContext context) {
    final Color base = HabitHeatmapColor.of(habit.colorHex);
    final DateTime today = DateTime.now();
    final DateTime start = today.subtract(Duration(days: days - 1));
    final int crossAxisCount = days == 30 ? 10 : 15;

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: crossAxisCount,
      mainAxisSpacing: 5,
      crossAxisSpacing: 5,
      childAspectRatio: 1,
      children: <Widget>[
        for (int i = 0; i < days; i++)
          _DayCell(
            key: ValueKey<String>('${habit.id}-$i'),
            date: DateTime(start.year, start.month, start.day + i),
            done: completedKeys.contains(
              JalaliHelper.dateKey(
                DateTime(start.year, start.month, start.day + i),
              ),
            ),
            color: base,
            onTap: onDayTap,
          ),
      ],
    );
  }

}

abstract final class HabitHeatmapColor {
  static Color of(String hex) {
    final String raw = hex.replaceFirst('#', '');
    final int value = int.tryParse(raw, radix: 16) ?? 0xFF898D84;
    if (raw.length == 8) {
      return Color(value);
    }
    return Color(value | 0xFF000000);
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    super.key,
    required this.date,
    required this.done,
    required this.color,
    required this.onTap,
  });

  final DateTime date;
  final bool done;
  final Color color;
  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) {
    final String key = JalaliHelper.dateKey(date);
    return Tooltip(
      message: '${JalaliHelper.shortDate(date)} — '
          '${done ? 'انجام شد' : 'انجام نشد'}',
      child: Motion.press(
        context,
        InkWell(
          onTap: () async {
            await Haptics.toggle();
            onTap(key);
          },
          borderRadius: BorderRadius.circular(6),
          child: AnimatedContainer(
            duration: Motion.micro,
            curve: Curves.easeOutCubic,
            decoration: BoxDecoration(
              color: done ? color : AppColors.borderSubtle(context),
              borderRadius: BorderRadius.circular(6),
            ),
          ),
        ),
        minScale: 0.82,
      ),
    );
  }
}
