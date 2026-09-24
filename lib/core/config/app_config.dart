/// Runtime configuration shared across the app.
///
/// Values come from compile-time constants by default. For environment-specific
/// builds, supply them via `--dart-define` or wire them from a remote config
/// service. Keeping configuration in a plain immutable class makes it trivially
/// injectable and testable.
class AppConfig {
  /// Base URL for the HTTP API.
  final String apiBaseUrl;

  /// Connection timeout for outbound requests.
  final Duration connectTimeout;

  /// Receive timeout for inbound responses.
  final Duration receiveTimeout;

  /// Whether verbose network/diagnostic logging is enabled.
  final bool enableLogging;

  const AppConfig({
    this.apiBaseUrl = 'https://api.example.com',
    this.connectTimeout = const Duration(seconds: 15),
    this.receiveTimeout = const Duration(seconds: 15),
    this.enableLogging = true,
  });
}
