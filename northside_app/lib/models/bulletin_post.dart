// lib/models/bulletin_post.dart


class BulletinPost {
  const BulletinPost({
    required this.title,
    required this.subtitle,
    required this.date,
    this.imagePath,
    this.content = 'This is the full detail content for the article...',
    this.isPinned = false,
  });

  final String title;
  final String subtitle;
  final String? imagePath;
  final DateTime date;
  final String content;
  final bool isPinned;
}
