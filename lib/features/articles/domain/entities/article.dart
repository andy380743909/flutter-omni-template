/// Domain entity representing a single article in the feed.
///
/// Entities are plain, framework-agnostic value objects. This feature demonstrates
/// a list/collection use case (unlike the single-object [UserProfile]) so the
/// template also covers pagination and loading-more states.
class Article {
  final int id;
  final String title;
  final String body;
  final String author;

  const Article({
    required this.id,
    required this.title,
    required this.body,
    required this.author,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Article &&
          other.id == id &&
          other.title == title &&
          other.body == body &&
          other.author == author;

  @override
  int get hashCode => Object.hash(id, title, body, author);

  @override
  String toString() => 'Article(id: $id, title: $title, author: $author)';
}
