import 'dart:convert';

import 'package:app_template/core/errors/exceptions.dart';
import 'package:app_template/core/storage/key_value_storage.dart';
import 'package:app_template/features/articles/data/models/article_model.dart';

/// Local cache boundary for the articles feature.
///
/// Persists the last successfully fetched page so the UI can render something
/// while offline. Low-level failures become [CacheException]s.
abstract class ArticlesLocalDataSource {
  /// Returns the last cached article list, or `null` when none exists.
  Future<List<ArticleModel>?> getLastArticles();

  /// Caches an article list for offline use.
  Future<void> cacheArticles(List<ArticleModel> models);
}

/// [ArticlesLocalDataSource] backed by [KeyValueStorage].
class ArticlesLocalDataSourceImpl implements ArticlesLocalDataSource {
  static const String _storageKey = 'articles';

  final KeyValueStorage storage;

  const ArticlesLocalDataSourceImpl({required this.storage});

  @override
  Future<List<ArticleModel>?> getLastArticles() async {
    try {
      final String? raw = await storage.readString(key: _storageKey);
      if (raw == null) return null;
      final List<dynamic> list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((dynamic e) => ArticleModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw CacheException(message: 'Failed to read cached articles: $e');
    }
  }

  @override
  Future<void> cacheArticles(List<ArticleModel> models) async {
    try {
      final String value =
          jsonEncode(models.map((ArticleModel m) => m.toJson()).toList());
      final bool ok = await storage.writeString(key: _storageKey, value: value);
      if (!ok) {
        throw const CacheException(message: 'Failed to cache articles.');
      }
    } on CacheException {
      rethrow;
    } catch (e) {
      throw CacheException(message: 'Failed to cache articles: $e');
    }
  }
}
