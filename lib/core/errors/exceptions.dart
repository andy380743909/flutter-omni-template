/// Low-level exceptions thrown inside the data / datasource layer.
///
/// These represent unexpected, implementation-specific conditions (network
/// timeouts, JSON parse failures, storage I/O errors, ...). They are caught in
/// the data layer and converted into domain [Failure]s so the rest of the app
/// never has to reason about concrete exception types.
abstract class AppException implements Exception {
  final String message;

  const AppException({required this.message});

  @override
  String toString() => '${runtimeType.toString()}: $message';
}

/// Raised when the remote server returns an unexpected/invalid response.
class ServerException extends AppException {
  const ServerException({required super.message});
}

/// Raised when a network request fails (no connectivity, timeout, ...).
class NetworkException extends AppException {
  const NetworkException({required super.message});
}

/// Raised when a local cache / storage operation fails.
class CacheException extends AppException {
  const CacheException({required super.message});
}
