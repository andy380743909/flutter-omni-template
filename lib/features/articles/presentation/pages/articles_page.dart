import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:app_template/features/articles/presentation/state/articles_cubit.dart';
import 'package:app_template/features/articles/presentation/state/articles_state.dart';
import 'package:app_template/features/articles/presentation/widgets/article_list_item.dart';
import 'package:app_template/shared/widgets/app_error.dart';
import 'package:app_template/shared/widgets/app_loading.dart';

/// Example page demonstrating a remote, paginated list through the full Clean
/// Architecture flow:
/// UI -> Cubit -> UseCase -> Repository -> (Remote + Local) DataSources.
///
/// The [ArticlesCubit] is provided by an ancestor [BlocProvider] (see `app.dart`).
class ArticlesPage extends StatelessWidget {
  const ArticlesPage({super.key});

  /// Route name used by the app router.
  static const String routeName = '/articles';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Articles'),
        actions: <Widget>[
          IconButton(
            key: const Key('articles_refresh_button'),
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: () => context.read<ArticlesCubit>().loadFirstPage(),
          ),
        ],
      ),
      body: BlocBuilder<ArticlesCubit, ArticlesState>(
        builder: (BuildContext context, ArticlesState state) {
          if (state is ArticlesLoading) {
            return const AppLoading();
          } else if (state is ArticlesError) {
            return AppError(
              message: state.message,
              onRetry: () => context.read<ArticlesCubit>().loadFirstPage(),
            );
          } else if (state is ArticlesLoaded) {
            if (state.articles.isEmpty) {
              return const Center(child: Text('No articles yet.'));
            }
            return RefreshIndicator(
              onRefresh: () => context.read<ArticlesCubit>().loadFirstPage(),
              child: ListView.builder(
                itemCount: state.articles.length + (state.hasMore ? 1 : 0),
                itemBuilder: (BuildContext context, int index) {
                  if (index == state.articles.length) {
                    // Footer row: spinner while loading more, or a "Load more" button.
                    if (state.isLoadingMore) {
                      return const Padding(
                        padding: EdgeInsets.all(16),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: ElevatedButton(
                          key: const Key('articles_load_more_button'),
                          onPressed: () =>
                              context.read<ArticlesCubit>().loadMore(),
                          child: const Text('Load more'),
                        ),
                      ),
                    );
                  }
                  return ArticleListItem(article: state.articles[index]);
                },
              ),
            );
          }
          return const Center(child: Text('Pull to load articles.'));
        },
      ),
    );
  }
}
