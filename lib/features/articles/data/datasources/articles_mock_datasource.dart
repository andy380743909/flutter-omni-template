import 'package:app_template/features/articles/data/datasources/articles_remote_datasource.dart';
import 'package:app_template/features/articles/data/models/article_model.dart';
import 'package:app_template/features/articles/data/models/articles_page_model.dart';

/// In-memory mock implementation of [ArticlesRemoteDataSource].
///
/// Returns a fixed set of sample articles so the UI always has content even
/// when the real backend (e.g. the placeholder [AppConfig.apiBaseUrl]) is
/// unreachable. Handy for demos, offline previews, and tests.
class ArticlesMockDataSource implements ArticlesRemoteDataSource {
  const ArticlesMockDataSource();

  @override
  Future<ArticlesPageModel> getArticles(int page) async {
    // Simulate a short network round-trip so the loading state is exercised.
    await Future<void>.delayed(const Duration(milliseconds: 300));
    return const ArticlesPageModel(
      page: 1,
      hasMore: false,
      items: <ArticleModel>[
        ArticleModel(
          id: 1,
          title: 'Flutter 状态管理选型指南',
          body: 'Provider、Bloc 与 Riverpod 各自适用于不同规模的项目，理解它们的'
              '取舍才能做出正确选择。',
          author: 'Andy',
        ),
        ArticleModel(
          id: 2,
          title: 'SwiftUI 与 UIKit 的混合架构',
          body: '在大型存量项目中，可以渐进式地用 SwiftUI 重写单个页面，'
              '而非整体迁移。',
          author: 'Cui Panjun',
        ),
        ArticleModel(
          id: 3,
          title: 'iOS 真机调试的那些坑',
          body: '代码签名、Provisioning Profile 与 VM Service 端口转发，'
              '是每个 iOS 开发者都会踩的雷。',
          author: 'Dev Team',
        ),
        ArticleModel(
          id: 4,
          title: 'Dart 异步编程实战',
          body: 'Future、Stream 与 isolate 的正确用法，决定了 App 的'
              '流畅度与响应能力。',
          author: 'Flutter Weekly',
        ),
      ],
    );
  }
}
