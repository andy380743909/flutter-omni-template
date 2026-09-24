/// Build-time environment configuration.
///
/// Selected via `--dart-define=ENV=prod` (or `staging`). Defaults to `dev`.
enum Environment { dev, staging, prod }

/// Reads the active [Environment] from compile-time defines.
class AppEnvironment {
  /// Raw environment name supplied at build time.
  static const String name = String.fromEnvironment(
    'ENV',
    defaultValue: 'dev',
  );

  /// Parsed [Environment] value.
  static Environment get current {
    switch (name) {
      case 'prod':
        return Environment.prod;
      case 'staging':
        return Environment.staging;
      default:
        return Environment.dev;
    }
  }

  /// Convenience flag for production-specific behavior (e.g. reduced logging).
  static bool get isProduction => current == Environment.prod;

  /// Whether verbose network/diagnostic logging should be emitted.
  static bool get enableVerboseLogging => !isProduction;
}
