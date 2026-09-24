import 'package:flutter_test/flutter_test.dart';

import 'package:app_template/features/articles/data/models/articles_page_model.dart';
import 'package:app_template/features/articles/domain/entities/article.dart';
import 'package:app_template/features/articles/domain/entities/articles_page.dart';

void main() {
  group('ArticlesPageModel', () {
    test('fromJson parses the envelope', () {
      final ArticlesPageModel model = ArticlesPageModel.fromJson(
        <String, dynamic>{
          'items': <Map<String, dynamic>>[
            <String, dynamic>{
              'id': 1,
              'title': 't',
              'body': 'b',
              'author': 'a'
            },
            <String, dynamic>{
              'id': 2,
              'title': 't2',
              'body': 'b2',
              'author': 'a2'
            },
          ],
          'page': 1,
          'hasMore': true,
        },
      );
      expect(model.items.length, 2);
      expect(model.page, 1);
      expect(model.hasMore, isTrue);
    });

    test('fromJson throws when types are wrong', () {
      expect(
        () => ArticlesPageModel.fromJson(<String, dynamic>{
          'items': <dynamic>[],
          'page': '1',
          'hasMore': true,
        }),
        throwsA(isA<FormatException>()),
      );
    });

    test('toEntity maps to the domain page', () {
      final ArticlesPageModel model = ArticlesPageModel.fromJson(
        <String, dynamic>{
          'items': <Map<String, dynamic>>[
            <String, dynamic>{
              'id': 1,
              'title': 't',
              'body': 'b',
              'author': 'a'
            },
          ],
          'page': 2,
          'hasMore': false,
        },
      );
      final ArticlesPage page = model.toEntity();
      expect(page.items.length, 1);
      expect(
        page.items.first,
        const Article(id: 1, title: 't', body: 'b', author: 'a'),
      );
      expect(page.page, 2);
      expect(page.hasMore, isFalse);
    });

    test('model equality compares by value', () {
      final Map<String, dynamic> json = <String, dynamic>{
        'items': <Map<String, dynamic>>[
          <String, dynamic>{'id': 1, 'title': 't', 'body': 'b', 'author': 'a'},
        ],
        'page': 1,
        'hasMore': false,
      };
      expect(
          ArticlesPageModel.fromJson(json), ArticlesPageModel.fromJson(json));
    });
  });
}
