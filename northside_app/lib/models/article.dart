// lib/models/article.dart

class Article {
  const Article({
    required this.title,
    required this.subtitle,
    this.imagePath,
    this.content = 'This is the full detail content for the article...',
  });

  final String title;
  final String subtitle;
  final String? imagePath;
  final String content;
}
