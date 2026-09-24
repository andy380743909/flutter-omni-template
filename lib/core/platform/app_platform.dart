/// The set of platforms this template targets.
///
/// Flutter's own [TargetPlatform] does not include HarmonyOS, so we define our
/// own enumeration and resolve it in [PlatformInfo].
enum AppPlatform {
  android,
  ios,
  web,
  windows,
  macOS,
  linux,
  ohos,
}
