import 'package:app_template/core/errors/failures.dart';
import 'package:app_template/core/utils/result.dart';
import 'package:app_template/features/articles/domain/entities/articles_page.dart';

/// Abstraction the domain layer depends on. The data layer provides the
/// concrete implementation; the UI never sees the implementation details.
abstract class ArticlesRepository {
  /// Returns page [page] of the article feed.
  ///
  /// Remote-first; on a network failure it falls back to the last cached page
  /// (page 1 only), returning a [NetworkFailure] when neither source is available.
  Future<Result<ArticlesPage, Failure>> getArticles(int page);
}
