import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:madaar/core/theme/app_colors.dart';
import 'package:madaar/core/theme/app_theme.dart';
import 'package:madaar/core/utils/motion.dart';
import 'package:madaar/core/widgets/bento_card.dart';

void main() {
  testWidgets('تم تاریک و روشن با BentoCard سازگاراند', (tester) async {
    for (final ThemeData theme in <ThemeData>[AppTheme.dark, AppTheme.light]) {
      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: const Scaffold(
            body: Center(
              child: BentoCard(child: SizedBox(height: 40, width: 120)),
            ),
          ),
        ),
      );
      expect(find.byType(BentoCard), findsOneWidget);
      final BuildContext context = tester.element(find.byType(BentoCard));
      expect(
        Theme.of(context).brightness,
        theme.brightness,
      );
      expect(AppColors.borderSubtle(context), isA<Color>());
    }
  });

  testWidgets('reduced motion انیمیشن ورودی را حذف میکند', (tester) async {
    late bool reduced;
    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(disableAnimations: true),
        child: Builder(
          builder: (BuildContext context) {
            reduced = Motion.reduced(context);
            return const SizedBox.shrink();
          },
        ),
      ),
    );
    expect(reduced, true);
  });
}
