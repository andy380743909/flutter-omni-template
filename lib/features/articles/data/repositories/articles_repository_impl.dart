import 'package:app_template/core/errors/exceptions.dart';
import 'package:app_template/core/errors/failures.dart';
import 'package:app_template/core/utils/result.dart';
import 'package:app_template/features/articles/data/datasources/articles_local_datasource.dart';
import 'package:app_template/features/articles/data/datasources/articles_remote_datasource.dart';
import 'package:app_template/features/articles/data/datasources/articles_mock_datasource.dart';
import 'package:app_template/features/articles/data/models/article_model.dart';
import 'package:app_template/features/articles/data/models/articles_page_model.dart';
import 'package:app_template/features/articles/domain/entities/articles_page.dart';
import 'package:app_template/features/articles/domain/repositories/articles_repository.dart';

/// Concrete [ArticlesRepository]: remote-first with a local cache fallback.
///
/// Catches low-level [AppException]s and converts them into domain [Failure]s,
/// never leaking implementation details above the data layer.
class ArticlesRepositoryImpl implements ArticlesRepository {
  final ArticlesRemoteDataSource remoteDataSource;
  final ArticlesLocalDataSource localDataSource;
  final ArticlesMockDataSource mockDataSource;

  const ArticlesRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    this.mockDataSource = const ArticlesMockDataSource(),
  });

  @override
  Future<Result<ArticlesPage, Failure>> getArticles(int page) async {
    try {
      final ArticlesPageModel model = await remoteDataSource.getArticles(page);
      // Only the first page is cached (the offline "last known" snapshot).
      if (page == 1) {
        await localDataSource.cacheArticles(model.items);
      }
      return Result.success(model.toEntity());
    } on ServerException catch (e) {
      return Result.failure(ServerFailure(message: e.message));
    } on NetworkException {
      // Offline: fall back to the cached first page when available.
      if (page == 1) {
        try {
          final List<ArticleModel>? cached =
              await localDataSource.getLastArticles();
          if (cached != null && cached.isNotEmpty) {
            return Result.success(
              ArticlesPage(
                items: cached.map((ArticleModel m) => m.toEntity()).toList(),
                page: 1,
                hasMore: false,
              ),
            );
          }
        } on CacheException {
          // ignore, fall through to mock sample data
        }
        // No cache available: serve mock sample articles so the UI has content.
        return Result.success(
          (await mockDataSource.getArticles(page)).toEntity(),
        );
      }
      return const Result.failure(
        NetworkFailure(message: 'No network and no cached articles.'),
      );
    } on CacheException catch (e) {
      return Result.failure(CacheFailure(message: e.message));
    } catch (e) {
      return Result.failure(UnknownFailure(message: e.toString()));
    }
  }
}
