import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:app_template/features/articles/domain/entities/article.dart';
import 'package:app_template/features/articles/presentation/pages/articles_page.dart';
import 'package:app_template/features/articles/presentation/state/articles_cubit.dart';
import 'package:app_template/features/articles/presentation/state/articles_state.dart';

class MockArticlesCubit extends MockCubit<ArticlesState>
    implements ArticlesCubit {}

void main() {
  late MockArticlesCubit cubit;

  setUp(() {
    cubit = MockArticlesCubit();
    when(() => cubit.state).thenReturn(const ArticlesInitial());
  });

  Future<void> pumpPage(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<ArticlesCubit>.value(
          value: cubit,
          child: const ArticlesPage(),
        ),
      ),
    );
    await tester.pump();
  }

  const Article article =
      Article(id: 1, title: 'Hello', body: 'world', author: 'Ada');

  testWidgets('shows the start hint when initial', (WidgetTester tester) async {
    when(() => cubit.state).thenReturn(const ArticlesInitial());
    await pumpPage(tester);
    expect(find.byIcon(Icons.refresh), findsOneWidget);
    expect(find.text('Pull to load articles.'), findsOneWidget);
  });

  testWidgets('shows a loading indicator when loading', (
    WidgetTester tester,
  ) async {
    when(() => cubit.state).thenReturn(const ArticlesLoading());
    await pumpPage(tester);
    expect(find.byType(CircularProgressIndicator), findsWidgets);
  });

  testWidgets('shows the list when loaded', (WidgetTester tester) async {
    when(() => cubit.state).thenReturn(ArticlesLoaded(
      articles: const <Article>[article],
      page: 1,
      hasMore: false,
    ));
    await pumpPage(tester);
    expect(find.text('Hello'), findsOneWidget);
    expect(find.textContaining('Ada'), findsOneWidget);
  });

  testWidgets('shows a Load more button when hasMore', (
    WidgetTester tester,
  ) async {
    when(() => cubit.state).thenReturn(ArticlesLoaded(
      articles: const <Article>[article],
      page: 1,
      hasMore: true,
    ));
    await pumpPage(tester);
    expect(
      find.byKey(const Key('articles_load_more_button')),
      findsOneWidget,
    );
  });

  testWidgets('shows an error message with a retry button', (
    WidgetTester tester,
  ) async {
    when(() => cubit.state).thenReturn(const ArticlesError('boom'));
    await pumpPage(tester);
    expect(find.text('boom'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);
  });

  testWidgets('tapping refresh calls loadFirstPage()', (
    WidgetTester tester,
  ) async {
    when(() => cubit.state).thenReturn(ArticlesLoaded(
      articles: const <Article>[article],
      page: 1,
      hasMore: false,
    ));
    when(() => cubit.loadFirstPage()).thenAnswer((_) async {});

    await pumpPage(tester);
    await tester.tap(find.byKey(const Key('articles_refresh_button')));
    await tester.pumpAndSettle();

    verify(() => cubit.loadFirstPage()).called(1);
  });
}
