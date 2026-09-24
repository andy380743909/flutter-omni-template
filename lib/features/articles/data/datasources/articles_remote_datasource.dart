import 'package:app_template/core/errors/exceptions.dart';
import 'package:app_template/core/network/http_client.dart';
import 'package:app_template/features/articles/data/models/articles_page_model.dart';

/// Remote boundary for the articles feature.
///
/// Talks to the [HttpClient] abstraction (never [dio] directly). Low-level
/// conditions are surfaced as [AppException]s for the repository to translate.
abstract class ArticlesRemoteDataSource {
  /// Fetches page [page] of the article feed.
  Future<ArticlesPageModel> getArticles(int page);
}

/// [ArticlesRemoteDataSource] backed by the [HttpClient] abstraction.
class ArticlesRemoteDataSourceImpl implements ArticlesRemoteDataSource {
  final HttpClient httpClient;

  const ArticlesRemoteDataSourceImpl({required this.httpClient});

  @override
  Future<ArticlesPageModel> getArticles(int page) async {
    try {
      final Map<String, dynamic> json = await httpClient.get(
        '/articles',
        queryParameters: <String, dynamic>{'page': page, 'pageSize': 10},
      );
      return ArticlesPageModel.fromJson(json);
    } on FormatException catch (e) {
      throw ServerException(message: 'Invalid articles response: $e');
    } catch (e) {
      // The HttpClient may surface transport errors (e.g. a DioException) that
      // are not AppExceptions; normalize them to a NetworkException.
      throw NetworkException(message: 'Failed to fetch articles: $e');
    }
  }
}
