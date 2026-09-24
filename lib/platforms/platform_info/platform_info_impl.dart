import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kIsWeb;
import 'package:flutter/services.dart'
    show MethodChannel, MissingPluginException;

import 'package:app_template/core/platform/app_platform.dart';
import 'package:app_template/core/platform/platform_info.dart';

/// Method channel used to ask the HarmonyOS native side whether we are running
/// on ohos. The native handler is registered only by Flutter-OH projects; on
/// the 6 official Flutter platforms the call is a safe no-op (MissingPlugin).
const MethodChannel _platformChannel = MethodChannel('app_template/platform');

/// Concrete [PlatformInfo] that resolves the current platform.
///
/// On the 6 official Flutter platforms the resolution is purely synchronous via
/// [defaultTargetPlatform]. HarmonyOS detection is deferred to [detectOhos],
/// which asynchronously queries the native side and is safe to call anywhere.
class PlatformInfoImpl implements PlatformInfo {
  AppPlatform _current;

  PlatformInfoImpl() : _current = _resolveSync();

  /// Synchronously maps [defaultTargetPlatform] (web excluded).
  static AppPlatform _resolveSync() {
    if (kIsWeb) return AppPlatform.web;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return AppPlatform.android;
      case TargetPlatform.iOS:
        return AppPlatform.ios;
      case TargetPlatform.windows:
        return AppPlatform.windows;
      case TargetPlatform.macOS:
        return AppPlatform.macOS;
      case TargetPlatform.linux:
        return AppPlatform.linux;
      case TargetPlatform.fuchsia:
        return AppPlatform.android;
    }
  }

  @override
  AppPlatform get current => _current;

  @override
  bool get isOhos => _current == AppPlatform.ohos;

  @override
  bool get isWeb => _current == AppPlatform.web;

  @override
  bool get isMobile =>
      _current == AppPlatform.android ||
      _current == AppPlatform.ios ||
      _current == AppPlatform.ohos;

  @override
  bool get isDesktop =>
      _current == AppPlatform.windows ||
      _current == AppPlatform.macOS ||
      _current == AppPlatform.linux;

  @override
  Future<void> detectOhos() async {
    // Web can never be HarmonyOS.
    if (kIsWeb) return;
    try {
      final bool? isOhos = await _platformChannel.invokeMethod<bool>('is_ohos');
      if (isOhos == true) {
        _current = AppPlatform.ohos;
      }
    } on MissingPluginException {
      // No native handler registered (the 6 official platforms): stay non-ohos.
    } catch (_) {
      // Any other unexpected error must not break the app on standard platforms.
    }
  }
}
