import 'package:flutter_test/flutter_test.dart';

import 'package:app_template/features/articles/data/models/article_model.dart';
import 'package:app_template/features/articles/domain/entities/article.dart';

void main() {
  group('ArticleModel', () {
    const Article entity = Article(id: 1, title: 't', body: 'b', author: 'a');

    test('fromJson reads fields', () {
      final ArticleModel model = ArticleModel.fromJson(<String, dynamic>{
        'id': 1,
        'title': 't',
        'body': 'b',
        'author': 'a',
      });
      expect(model.id, 1);
      expect(model.author, 'a');
    });

    test('fromJson throws when id is not an int', () {
      expect(
        () => ArticleModel.fromJson(<String, dynamic>{
          'id': '1',
          'title': 't',
          'body': 'b',
          'author': 'a',
        }),
        throwsA(isA<FormatException>()),
      );
    });

    test('toJson round-trips', () {
      final ArticleModel model = ArticleModel.fromEntity(entity);
      expect(model.toJson(), <String, dynamic>{
        'id': 1,
        'title': 't',
        'body': 'b',
        'author': 'a',
      });
    });

    test('entity mapping is symmetric', () {
      final ArticleModel model = ArticleModel.fromEntity(entity);
      expect(model.toEntity(), entity);
    });

    test('equality compares by value', () {
      expect(
        const ArticleModel(id: 1, title: 'A', body: 'b', author: 'a'),
        const ArticleModel(id: 1, title: 'A', body: 'b', author: 'a'),
      );
      expect(
        const ArticleModel(id: 1, title: 'A', body: 'b', author: 'a') ==
            const ArticleModel(id: 2, title: 'A', body: 'b', author: 'a'),
        isFalse,
      );
    });
  });
}
