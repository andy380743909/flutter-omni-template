/// Platform-agnostic HTTP client abstraction.
///
/// The app depends on this interface (never on [dio] directly) so the concrete
/// implementation can be swapped or mocked in tests. See [DioHttpClient] for
/// the production implementation.
abstract class HttpClient {
  /// Performs a GET request and returns the decoded JSON object.
  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  });

  /// Performs a POST request with an optional JSON [data] body.
  Future<Map<String, dynamic>> post(
    String path, {
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? data,
  });

  /// Performs a PUT request with an optional JSON [data] body.
  Future<Map<String, dynamic>> put(
    String path, {
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? data,
  });

  /// Performs a DELETE request.
  Future<Map<String, dynamic>> delete(
    String path, {
    Map<String, dynamic>? queryParameters,
  });
}
