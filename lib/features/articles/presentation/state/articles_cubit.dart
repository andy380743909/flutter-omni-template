import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:app_template/features/articles/domain/entities/article.dart';
import 'package:app_template/features/articles/domain/usecases/get_articles.dart';
import 'package:app_template/features/articles/presentation/state/articles_state.dart';

/// Stateful coordinator for the articles feature.
///
/// The Cubit only orchestrates state transitions; all business rules live in the
/// injected use case. It exposes [loadFirstPage] and [loadMore] (pagination).
class ArticlesCubit extends Cubit<ArticlesState> {
  final GetArticles getArticles;

  /// Page size requested from the API; must match the backend contract.
  static const int pageSize = 10;

  ArticlesCubit({required this.getArticles}) : super(const ArticlesInitial());

  /// Loads (or reloads) the first page of the feed.
  Future<void> loadFirstPage() async {
    emit(const ArticlesLoading());
    final result = await getArticles(const GetArticlesParams(1));
    result.fold(
      onSuccess: (articlesPage) => emit(
        ArticlesLoaded(
          articles: articlesPage.items,
          page: articlesPage.page,
          hasMore: articlesPage.hasMore,
        ),
      ),
      onFailure: (failure) => emit(ArticlesError(failure.message)),
    );
  }

  /// Appends the next page when the current page reports [ArticlesLoaded.hasMore].
  /// No-op if not in a loaded state, already loading more, or no more pages.
  Future<void> loadMore() async {
    final ArticlesState current = state;
    if (current is! ArticlesLoaded ||
        !current.hasMore ||
        current.isLoadingMore) {
      return;
    }

    // Show the existing list with a bottom spinner while fetching the next page.
    emit(
      ArticlesLoaded(
        articles: current.articles,
        page: current.page,
        hasMore: current.hasMore,
        isLoadingMore: true,
      ),
    );

    final result = await getArticles(GetArticlesParams(current.page + 1));
    result.fold(
      onSuccess: (articlesPage) => emit(
        ArticlesLoaded(
          articles: <Article>[...current.articles, ...articlesPage.items],
          page: articlesPage.page,
          hasMore: articlesPage.hasMore,
        ),
      ),
      onFailure: (failure) => emit(ArticlesError(failure.message)),
    );
  }
}
