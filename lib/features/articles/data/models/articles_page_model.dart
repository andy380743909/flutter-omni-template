import 'package:app_template/features/articles/data/models/article_model.dart';
import 'package:app_template/features/articles/domain/entities/articles_page.dart';

/// Data-layer model for a page of [ArticleModel]s.
///
/// Parses the envelope returned by the feed endpoint:
/// `{ "items": [...], "page": 1, "hasMore": true }`.
class ArticlesPageModel {
  final List<ArticleModel> items;
  final int page;
  final bool hasMore;

  const ArticlesPageModel({
    required this.items,
    required this.page,
    required this.hasMore,
  });

  /// Builds a page model from a JSON envelope.
  factory ArticlesPageModel.fromJson(Map<String, dynamic> json) {
    final dynamic rawItems = json['items'];
    if (rawItems is! List) {
      throw const FormatException('ArticlesPageModel requires a List "items".');
    }
    final List<ArticleModel> items = rawItems
        .map((dynamic e) => ArticleModel.fromJson(e as Map<String, dynamic>))
        .toList();

    final dynamic rawPage = json['page'];
    if (rawPage is! int) {
      throw const FormatException('ArticlesPageModel requires an int "page".');
    }

    final dynamic rawHasMore = json['hasMore'];
    if (rawHasMore is! bool) {
      throw const FormatException(
          'ArticlesPageModel requires a bool "hasMore".');
    }

    return ArticlesPageModel(items: items, page: rawPage, hasMore: rawHasMore);
  }

  /// Converts this model page into a domain [ArticlesPage].
  ArticlesPage toEntity() => ArticlesPage(
        items: items.map((ArticleModel m) => m.toEntity()).toList(),
        page: page,
        hasMore: hasMore,
      );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ArticlesPageModel) return false;
    if (page != other.page || hasMore != other.hasMore) return false;
    if (items.length != other.items.length) return false;
    for (int i = 0; i < items.length; i++) {
      if (items[i] != other.items[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hash(page, hasMore, Object.hashAll(items));

  @override
  String toString() =>
      'ArticlesPageModel(page: $page, hasMore: $hasMore, items: ${items.length})';
}
