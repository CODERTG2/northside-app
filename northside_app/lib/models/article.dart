// lib/models/article.dart

class Article {
  const Article({
    required this.title,
    required this.subtitle,
    this.imagePath, // Image is optional
    required this.content,
  });

  final String title;
  final String subtitle;
  final String? imagePath;
  final String content;
}
