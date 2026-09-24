import 'package:logger/logger.dart' as log;

/// Logging abstraction used across the app.
///
/// Business code must use this interface instead of `print`. The default
/// implementation wraps the popular `logger` package.
abstract class Logger {
  const Logger();

  /// Most verbose tracing information.
  void verbose(String message);

  /// Debug-level diagnostics (dev only in practice).
  void debug(String message);

  /// Informational messages.
  void info(String message);

  /// Warnings that do not prevent operation.
  void warning(String message);

  /// Errors, optionally with the original [error] and [stackTrace].
  void error(String message, [Object? error, StackTrace? stackTrace]);
}

/// Default [Logger] implementation backed by the `logger` package.
class DefaultLogger implements Logger {
  final log.Logger _delegate;

  DefaultLogger({log.Logger? delegate})
      : _delegate = delegate ??
            log.Logger(
              printer: log.PrettyPrinter(
                methodCount: 0,
                errorMethodCount: 8,
                lineLength: 100,
                colors: true,
                printEmojis: false,
              ),
            );

  @override
  void verbose(String message) => _delegate.t(message);

  @override
  void debug(String message) => _delegate.d(message);

  @override
  void info(String message) => _delegate.i(message);

  @override
  void warning(String message) => _delegate.w(message);

  @override
  void error(String message, [Object? error, StackTrace? stackTrace]) =>
      _delegate.e(message, error: error, stackTrace: stackTrace);
}
