import 'package:dio/dio.dart';

import 'package:app_template/core/network/http_client.dart';

/// [HttpClient] implementation backed by [dio].
///
/// A pre-configured [Dio] instance (with base URL, timeouts, interceptors...)
/// is injected via the DI container. Responses are normalized to a JSON object.
class DioHttpClient implements HttpClient {
  final Dio dio;

  const DioHttpClient(this.dio);

  Map<String, dynamic> _toMap(dynamic data) {
    if (data == null) return <String, dynamic>{};
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    throw const FormatException(
      'Expected a JSON object response body but received a non-object.',
    );
  }

  @override
  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    final Response<dynamic> response = await dio.get<dynamic>(
      path,
      queryParameters: queryParameters,
    );
    return _toMap(response.data);
  }

  @override
  Future<Map<String, dynamic>> post(
    String path, {
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? data,
  }) async {
    final Response<dynamic> response = await dio.post<dynamic>(
      path,
      queryParameters: queryParameters,
      data: data,
    );
    return _toMap(response.data);
  }

  @override
  Future<Map<String, dynamic>> put(
    String path, {
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? data,
  }) async {
    final Response<dynamic> response = await dio.put<dynamic>(
      path,
      queryParameters: queryParameters,
      data: data,
    );
    return _toMap(response.data);
  }

  @override
  Future<Map<String, dynamic>> delete(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    final Response<dynamic> response = await dio.delete<dynamic>(
      path,
      queryParameters: queryParameters,
    );
    return _toMap(response.data);
  }
}
