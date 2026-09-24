import 'package:app_template/core/errors/failures.dart';
import 'package:app_template/core/usecases/usecase.dart';
import 'package:app_template/core/utils/result.dart';
import 'package:app_template/features/articles/domain/entities/articles_page.dart';
import 'package:app_template/features/articles/domain/repositories/articles_repository.dart';

/// Parameters for [GetArticles]: which 1-based [page] to fetch.
class GetArticlesParams {
  final int page;

  const GetArticlesParams(this.page);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GetArticlesParams && other.page == page;

  @override
  int get hashCode => page.hashCode;
}

/// Use case: read a page of the article feed.
class GetArticles implements UseCase<ArticlesPage, GetArticlesParams> {
  final ArticlesRepository repository;

  const GetArticles({required this.repository});

  @override
  Future<Result<ArticlesPage, Failure>> call(GetArticlesParams params) =>
      repository.getArticles(params.page);
}
