import 'package:app_template/features/articles/domain/entities/article.dart';

/// Immutable state for the articles feature.
///
/// Four explicit states mirror the loading lifecycle: initial, loading, loaded
/// (with pagination metadata) and error. States are handwritten (no code
/// generation) so the template stays dependency-light.
sealed class ArticlesState {
  const ArticlesState();
}

/// Shown before the first load attempt.
final class ArticlesInitial extends ArticlesState {
  const ArticlesInitial();

  @override
  bool operator ==(Object other) => other is ArticlesInitial;

  @override
  int get hashCode => 0;
}

/// Shown while the first page is in flight.
final class ArticlesLoading extends ArticlesState {
  const ArticlesLoading();

  @override
  bool operator ==(Object other) => other is ArticlesLoading;

  @override
  int get hashCode => 1;
}

/// Shown once articles are available. Carries pagination metadata so the UI can
/// render a "load more" affordance and a bottom spinner while fetching the next
/// page.
final class ArticlesLoaded extends ArticlesState {
  final List<Article> articles;
  final int page;
  final bool hasMore;
  final bool isLoadingMore;

  ArticlesLoaded({
    required this.articles,
    required this.page,
    required this.hasMore,
    this.isLoadingMore = false,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ArticlesLoaded &&
          other.page == page &&
          other.hasMore == hasMore &&
          other.isLoadingMore == isLoadingMore &&
          _listEquals(other.articles, articles);

  @override
  int get hashCode =>
      Object.hash(page, hasMore, isLoadingMore, Object.hashAll(articles));

  bool _listEquals(List<Article> a, List<Article> b) {
    if (identical(a, b)) return true;
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}

/// Shown when an operation fails.
final class ArticlesError extends ArticlesState {
  final String message;

  const ArticlesError(this.message);

  @override
  bool operator ==(Object other) =>
      other is ArticlesError && other.message == message;

  @override
  int get hashCode => message.hashCode;
}
