import 'package:flutter/material.dart';

import 'package:app_template/app/app.dart';
import 'package:app_template/app/bootstrap.dart';

/// Application entry point.
///
/// `bootstrap()` initializes platform bindings, dependency injection and
/// (optionally) HarmonyOS detection, then `runApp` starts the widget tree.
Future<void> main() async {
  await bootstrap();
  runApp(const MyApp());
}
