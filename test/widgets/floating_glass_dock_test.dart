import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:madaar/core/widgets/floating_glass_dock.dart';

void main() {
  testWidgets('داک پنج تب و دکمه مرکزی ثبت سریع دارد', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: const SizedBox.expand(),
          bottomNavigationBar: FloatingGlassDock(
            currentIndex: 0,
            onDestinationSelected: (_) {},
            onQuickAdd: () {},
          ),
        ),
      ),
    );

    expect(find.text('امروز'), findsOneWidget);
    expect(find.text('کارها'), findsOneWidget);
    expect(find.text('عادت‌ها'), findsOneWidget);
    expect(find.text('جیب'), findsOneWidget);
    expect(find.text('خلوت'), findsOneWidget);
    expect(find.byIcon(Icons.add_rounded), findsOneWidget);
  });
}
