import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:app_template/features/articles/domain/entities/article.dart';
import 'package:app_template/features/articles/presentation/widgets/article_list_item.dart';

void main() {
  group('ArticleListItem', () {
    const Article article = Article(
      id: 1,
      title: 'Hello',
      body: 'world body',
      author: 'Ada',
    );

    testWidgets('renders title and author', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: ArticleListItem(article: article)),
        ),
      );

      expect(find.text('Hello'), findsOneWidget);
      expect(find.textContaining('Ada'), findsOneWidget);
      expect(find.byType(ArticleListItem), findsOneWidget);
    });

    testWidgets('renders the article id in the avatar', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: ArticleListItem(article: article)),
        ),
      );

      expect(find.text('1'), findsOneWidget);
    });
  });
}
