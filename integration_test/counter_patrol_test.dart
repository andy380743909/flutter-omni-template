import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

import 'package:app_template/app/app.dart';
import 'package:app_template/app/bootstrap.dart';

/// Patrol-powered UI automation demo.
///
/// Patrol shines for *system-level* interactions (permission dialogs, deep
/// links, the system share sheet, notifications) which plain WidgetTester
/// cannot drive. This template test demonstrates the structure; the commented
/// `$.native` calls show where real device interactions would go.
///
/// Run with: `patrol test integration_test/counter_patrol_test.dart`
void main() {
  patrolTest(
    'counter tap increments the value (patrol demo)',
    ($) async {
      await bootstrap();
      await $.pumpWidgetAndSettle(const MyApp());

      // Standard widget interaction via the underlying WidgetTester.
      await $.tester.tap(find.byKey(const Key('counter_increment_button')));
      await $.pumpAndSettle();

      // --- System-level interaction placeholders (require a real device) -----
      // await $.native.grantPermissionWhenInUse();   // location permission
      // await $.native.tap(Selector(text: 'Allow'));  // OS dialog
      // await $.native.openApp();                      // launch from home
      // ----------------------------------------------------------------------
    },
  );
}
