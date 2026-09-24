import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:app_template/core/errors/failures.dart';
import 'package:app_template/core/utils/result.dart';
import 'package:app_template/features/articles/domain/entities/article.dart';
import 'package:app_template/features/articles/domain/entities/articles_page.dart';
import 'package:app_template/features/articles/domain/usecases/get_articles.dart';
import 'package:app_template/features/articles/presentation/state/articles_cubit.dart';
import 'package:app_template/features/articles/presentation/state/articles_state.dart';

class MockGetArticles extends Mock implements GetArticles {}

void main() {
  late MockGetArticles getArticles;

  setUp(() => getArticles = MockGetArticles());

  ArticlesCubit build() => ArticlesCubit(getArticles: getArticles);

  const Article a1 = Article(id: 1, title: 't', body: 'b', author: 'a');
  const Article a2 =
      Article(id: 2, title: 't2', body: 'b2', author: 'a2');
  const ArticlesPage page1 =
      ArticlesPage(items: <Article>[a1], page: 1, hasMore: true);
  const ArticlesPage page2 =
      ArticlesPage(items: <Article>[a2], page: 2, hasMore: false);

  blocTest<ArticlesCubit, ArticlesState>(
    'emits [loading, loaded] when loadFirstPage succeeds',
    build: build,
    setUp: () => when(() => getArticles(const GetArticlesParams(1))).thenAnswer(
      (_) async => const Result<ArticlesPage, Failure>.success(page1),
    ),
    act: (ArticlesCubit cubit) => cubit.loadFirstPage(),
    expect: () => <ArticlesState>[
      const ArticlesLoading(),
      ArticlesLoaded(articles: <Article>[a1], page: 1, hasMore: true),
    ],
  );

  blocTest<ArticlesCubit, ArticlesState>(
    'emits [loading, error] when loadFirstPage fails',
    build: build,
    setUp: () => when(() => getArticles(const GetArticlesParams(1))).thenAnswer(
      (_) async =>
          const Result<ArticlesPage, Failure>.failure(ServerFailure(message: 'fail')),
    ),
    act: (ArticlesCubit cubit) => cubit.loadFirstPage(),
    expect: () => const <ArticlesState>[
      ArticlesLoading(),
      ArticlesError('fail'),
    ],
  );

  blocTest<ArticlesCubit, ArticlesState>(
    'loadMore shows a spinner then appends the next page',
    build: build,
    seed: () => ArticlesLoaded(articles: <Article>[a1], page: 1, hasMore: true),
    setUp: () => when(() => getArticles(const GetArticlesParams(2))).thenAnswer(
      (_) async => const Result<ArticlesPage, Failure>.success(page2),
    ),
    act: (ArticlesCubit cubit) => cubit.loadMore(),
    expect: () => <ArticlesState>[
      ArticlesLoaded(
        articles: <Article>[a1],
        page: 1,
        hasMore: true,
        isLoadingMore: true,
      ),
      ArticlesLoaded(
        articles: <Article>[a1, a2],
        page: 2,
        hasMore: false,
      ),
    ],
  );

  blocTest<ArticlesCubit, ArticlesState>(
    'loadMore is a no-op when not in a loaded state',
    build: build,
    seed: () => const ArticlesInitial(),
    act: (ArticlesCubit cubit) => cubit.loadMore(),
    expect: () => const <ArticlesState>[],
  );
}
