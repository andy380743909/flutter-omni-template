import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:app_template/features/counter/domain/entities/counter.dart';
import 'package:app_template/features/counter/presentation/widgets/counter_display.dart';

void main() {
  group('CounterDisplay', () {
    testWidgets('renders the counter value', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CounterDisplay(counter: const Counter(value: 42)),
          ),
        ),
      );

      expect(find.text('42'), findsOneWidget);
      expect(find.byType(CounterDisplay), findsOneWidget);
    });

    testWidgets('shows the description label', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CounterDisplay(counter: const Counter(value: 0)),
          ),
        ),
      );

      expect(
        find.text('You have pushed the button this many times:'),
        findsOneWidget,
      );
    });
  });
}
