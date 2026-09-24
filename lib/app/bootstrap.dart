import 'package:flutter/widgets.dart';

import 'package:app_template/core/platform/platform_info.dart';
import 'package:app_template/di/injection_container.dart' as di;

/// Performs all startup-time initialization before `runApp`.
///
/// Order:
///   1. Ensure Flutter bindings are initialized (needed for plugins).
///   2. Wire up the dependency graph via [di.initDi].
///   3. Optionally detect HarmonyOS (safe no-op on the 6 official platforms).
Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.initDi();
  // HarmonyOS detection only matters on real Flutter-OH devices; on the 6
  // official Flutter platforms this resolves to a no-op and never throws.
  await di.sl<PlatformInfo>().detectOhos();
}
