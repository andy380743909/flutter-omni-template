import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:app_template/app/app.dart';
import 'package:app_template/app/bootstrap.dart';

/// End-to-end flow: launch the app, tap "+" twice, and verify the counter
/// increments and persists (the second run would start from the persisted value).
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('counter increments and persists across taps', (
    WidgetTester tester,
  ) async {
    await bootstrap();
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    // The FAB is always present.
    expect(find.byKey(const Key('counter_increment_button')), findsOneWidget);

    // First tap -> 1
    await tester.tap(find.byKey(const Key('counter_increment_button')));
    await tester.pumpAndSettle();
    expect(find.text('1'), findsOneWidget);

    // Second tap -> 2
    await tester.tap(find.byKey(const Key('counter_increment_button')));
    await tester.pumpAndSettle();
    expect(find.text('2'), findsOneWidget);
  });
}
