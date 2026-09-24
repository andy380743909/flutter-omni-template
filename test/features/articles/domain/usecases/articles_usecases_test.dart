import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:app_template/core/errors/failures.dart';
import 'package:app_template/core/utils/result.dart';
import 'package:app_template/features/articles/domain/entities/article.dart';
import 'package:app_template/features/articles/domain/entities/articles_page.dart';
import 'package:app_template/features/articles/domain/repositories/articles_repository.dart';
import 'package:app_template/features/articles/domain/usecases/get_articles.dart';

class MockArticlesRepository extends Mock implements ArticlesRepository {}

void main() {
  late MockArticlesRepository repository;
  late GetArticles getArticles;

  setUp(() {
    repository = MockArticlesRepository();
    getArticles = GetArticles(repository: repository);
  });

  const ArticlesPage page = ArticlesPage(
    items: <Article>[Article(id: 1, title: 't', body: 'b', author: 'a')],
    page: 1,
    hasMore: false,
  );

  test('returns the page on success', () async {
    when(() => repository.getArticles(1)).thenAnswer(
      (_) async => const Result<ArticlesPage, Failure>.success(page),
    );

    final Result<ArticlesPage, Failure> result =
        await getArticles(const GetArticlesParams(1));

    expect(result.isSuccess, isTrue);
    expect(result.successOrNull, page);
    verify(() => repository.getArticles(1)).called(1);
  });

  test('propagates a failure', () async {
    when(() => repository.getArticles(1)).thenAnswer(
      (_) async =>
          Result<ArticlesPage, Failure>.failure(ServerFailure(message: 'boom')),
    );

    final Result<ArticlesPage, Failure> result =
        await getArticles(const GetArticlesParams(1));

    expect(result.isFailure, isTrue);
    expect(result.failureOrNull, isA<ServerFailure>());
  });
}
