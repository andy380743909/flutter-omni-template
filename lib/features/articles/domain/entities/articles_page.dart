import 'article.dart';

/// A single page of [Article]s returned by the feed endpoint.
///
/// Carries the items for this page plus pagination metadata (`page`, `hasMore`)
/// so the UI can decide when to show a "load more" affordance.
class ArticlesPage {
  final List<Article> items;
  final int page;
  final bool hasMore;

  const ArticlesPage({
    required this.items,
    required this.page,
    required this.hasMore,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ArticlesPage &&
          other.page == page &&
          other.hasMore == hasMore &&
          _listEquals(other.items, items);

  @override
  int get hashCode => Object.hash(page, hasMore, Object.hashAll(items));

  bool _listEquals(List<Article> a, List<Article> b) {
    if (identical(a, b)) return true;
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  @override
  String toString() =>
      'ArticlesPage(page: $page, hasMore: $hasMore, items: ${items.length})';
}
