// lib/models/announcement.dart

import 'bulletin_post.dart';

class Announcement {
  final String id;
  final String date;
  final String title;
  final String? description;
  final String createdBy;
  final DateTime createdAt;

  const Announcement({
    required this.id,
    required this.date,
    required this.title,
    this.description,
    required this.createdBy,
    required this.createdAt,
  });

  factory Announcement.fromJson(Map<String, dynamic> json) {
    return Announcement(
      id: json['\$oid'] ?? json['_id']?['\$oid'] ?? '',
      date: json['date'] ?? '',
      title: json['title'] ?? '',
      description: json['description'],
      createdBy: json['createdBy'] ?? '',
      createdAt: DateTime.parse(json['createdAt']?['\$date'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'title': title,
      'description': description,
      'createdBy': createdBy,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // Convert to BulletinPost for UI compatibility
  BulletinPost toBulletinPost() {
    return BulletinPost(
      title: title,
      subtitle: description ?? 'Posted by $createdBy',
      date: DateTime.tryParse(date) ?? createdAt,
      content: description ?? title,
      isPinned: false,
    );
  }
}
