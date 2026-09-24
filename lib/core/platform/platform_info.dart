import 'package:app_template/core/platform/app_platform.dart';

/// Resolves the current runtime platform and exposes convenience predicates.
///
/// Implementations live in `lib/platforms/platform_info` (per-platform). The
/// interface is storage/platform-agnostic so the rest of the app never branches
/// on concrete platforms directly.
abstract class PlatformInfo {
  /// The resolved [AppPlatform] for the current runtime.
  AppPlatform get current;

  /// `true` for phones/tablets: android, ios, ohos.
  bool get isMobile;

  /// `true` for desktop OSes: windows, macOS, linux.
  bool get isDesktop;

  /// `true` when running on the web.
  bool get isWeb;

  /// `true` only when running on HarmonyOS (Flutter-OH).
  bool get isOhos;

  /// Optionally detects HarmonyOS at runtime by querying the native side.
  ///
  /// On the 6 official Flutter platforms this is a safe no-op that never throws
  /// (the native method is simply not registered). Call it once during bootstrap
  /// on devices that may be running Flutter-OH.
  Future<void> detectOhos();
}
