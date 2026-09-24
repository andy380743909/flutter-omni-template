// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:app_template/app/app.dart';
import 'package:app_template/core/config/app_config.dart';
import 'package:app_template/di/injection_container.dart' as di;

void main() {
  setUp(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    // Counter persistence is backed by SharedPreferences; give it an in-memory
    // store so initDi() and the CounterCubit can run inside the test isolate.
    SharedPreferences.setMockInitialValues({});
    // initDi registers singletons; guard against double registration across
    // tests in this file.
    if (!di.sl.isRegistered<AppConfig>()) {
      await di.initDi();
    }
  });

  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    // Verify that our counter starts at 0 (empty store defaults to 0).
    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    // Tap the '+' icon and trigger a frame.
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    // Verify that our counter has incremented.
    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);
  });
}
