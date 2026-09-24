/// Domain-level failures (recoverable, business-explainable errors).
///
/// These are distinct from [Exception]s: an [Exception] represents a low-level
/// unexpected condition thrown inside the data/datasource layer, while a
/// [Failure] is the domain-explainable result that is surfaced to the UI.
///
/// The data layer catches [Exception]s and converts them into [Failure]s which
/// travel up through [Result] to the presentation layer.
abstract class Failure {
  /// Human-readable, localized-ready message describing the failure.
  final String message;

  const Failure({required this.message});

  @override
  String toString() => '${runtimeType.toString()}: $message';
}

/// The remote server returned an error (HTTP 4xx/5xx, API-level error, etc.).
class ServerFailure extends Failure {
  const ServerFailure({required super.message});
}

/// The network is unreachable or a request timed out.
class NetworkFailure extends Failure {
  const NetworkFailure({required super.message});
}

/// A local cache / storage operation failed.
class CacheFailure extends Failure {
  const CacheFailure({required super.message});
}

/// Catch-all failure for any unexpected, unmapped error.
class UnknownFailure extends Failure {
  const UnknownFailure({required super.message});
}
