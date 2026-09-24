import 'package:app_template/features/articles/domain/entities/article.dart';

/// Data-layer model for [Article].
///
/// Handles (de)serialization for the network and cache layers. It is a thin
/// mapping wrapper over the domain [Article] entity.
class ArticleModel {
  final int id;
  final String title;
  final String body;
  final String author;

  const ArticleModel({
    required this.id,
    required this.title,
    required this.body,
    required this.author,
  });

  /// Builds a model from a JSON map (e.g. a network response or cached record).
  factory ArticleModel.fromJson(Map<String, dynamic> json) {
    final dynamic rawId = json['id'];
    final dynamic rawTitle = json['title'];
    final dynamic rawBody = json['body'];
    final dynamic rawAuthor = json['author'];
    if (rawId is! int) {
      throw const FormatException('ArticleModel requires an int "id".');
    }
    if (rawTitle is! String) {
      throw const FormatException('ArticleModel requires a String "title".');
    }
    if (rawBody is! String) {
      throw const FormatException('ArticleModel requires a String "body".');
    }
    if (rawAuthor is! String) {
      throw const FormatException('ArticleModel requires a String "author".');
    }
    return ArticleModel(
      id: rawId,
      title: rawTitle,
      body: rawBody,
      author: rawAuthor,
    );
  }

  /// Builds a model from a domain [Article] entity.
  factory ArticleModel.fromEntity(Article entity) => ArticleModel(
        id: entity.id,
        title: entity.title,
        body: entity.body,
        author: entity.author,
      );

  /// Serializes this model to a JSON map.
  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'title': title,
        'body': body,
        'author': author,
      };

  /// Converts this model back to a domain [Article] entity.
  Article toEntity() => Article(
        id: id,
        title: title,
        body: body,
        author: author,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ArticleModel &&
          other.id == id &&
          other.title == title &&
          other.body == body &&
          other.author == author;

  @override
  int get hashCode => Object.hash(id, title, body, author);

  @override
  String toString() => 'ArticleModel(id: $id, title: $title, author: $author)';
}
