import 'package:flutter/material.dart';

import 'package:app_template/features/articles/domain/entities/article.dart';

/// Reusable widget that displays a single [Article] as a list tile.
class ArticleListItem extends StatelessWidget {
  final Article article;

  const ArticleListItem({
    super.key,
    required this.article,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return ListTile(
      title: Text(article.title, style: theme.textTheme.titleMedium),
      subtitle: Text(
        '${article.author}  ·  ${article.body.length > 60 ? '${article.body.substring(0, 60)}…' : article.body}',
        style: theme.textTheme.bodySmall,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      leading: CircleAvatar(child: Text(article.id.toString())),
    );
  }
}
