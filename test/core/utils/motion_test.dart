import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:madaar/core/utils/motion.dart';

void main() {
  testWidgets('کاهش حرکت، انیمیشن فشار را کاملاً حذف میکند', (tester) async {
    await tester.pumpWidget(
      const MediaQuery(
        data: MediaQueryData(disableAnimations: true),
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Builder(
            builder: (BuildContext context) => Motion.press(
              context,
              const SizedBox(key: Key('child')),
            ),
          ),
        ),
      ),
    );

    expect(find.byKey(const Key('child')), findsOneWidget);
    expect(find.byType(Listener), findsNothing);
    expect(find.byType(AnimatedScale), findsNothing);
  });

  testWidgets('کاهش حرکت، تعویض محتوا را بدون AnimatedSwitcher میسازد',
      (tester) async {
    await tester.pumpWidget(
      const MediaQuery(
        data: MediaQueryData(disableAnimations: true),
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Builder(
            builder: (BuildContext context) => Motion.swap(
              context,
              const Text('یک'),
              'step-1',
            ),
          ),
        ),
      ),
    );

    expect(find.text('یک'), findsOneWidget);
    expect(find.byType(AnimatedSwitcher), findsNothing);
  });

  testWidgets('اعداد با فرمتدهندهی فارسی نمایش داده میشوند', (tester) async {
    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.rtl,
        child: Builder(
          builder: (BuildContext context) => Motion.number(
            context,
            125000,
            (num value) => '${value.round()} تومان',
            id: 'amount',
          ),
        ),
      ),
    );

    expect(find.text('125000 تومان'), findsOneWidget);
  });
}
