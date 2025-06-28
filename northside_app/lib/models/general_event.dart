// lib/models/general_event.dart

import 'article.dart';
import 'bulletin_post.dart';

class GeneralEvent {
  final String id;
  final String date;
  final String time;
  final String name;
  final String? description;
  final String? location;
  final String createdBy;
  final DateTime createdAt;

  const GeneralEvent({
    required this.id,
    required this.date,
    required this.time,
    required this.name,
    this.description,
    this.location,
    required this.createdBy,
    required this.createdAt,
  });

  factory GeneralEvent.fromJson(Map<String, dynamic> json) {
    return GeneralEvent(
      id: json['\$oid'] ?? json['_id']?['\$oid'] ?? '',
      date: json['date'] ?? '',
      time: json['time'] ?? '',
      name: json['name'] ?? '',
      description: json['description'],
      location: json['location'],
      createdBy: json['createdBy'] ?? '',
      createdAt: DateTime.parse(json['createdAt']?['\$date'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'time': time,
      'name': name,
      'description': description,
      'location': location,
      'createdBy': createdBy,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // Convert to Article for events display
  Article toArticle() {
    return Article(
      title: name,
      subtitle: '$time${location != null ? ' - $location' : ''}',
      content: description ?? '$name at $time${location != null ? ' in $location' : ''}.',
    );
  }

  // Convert to BulletinPost for bulletin display
  BulletinPost toBulletinPost() {
    return BulletinPost(
      title: name,
      subtitle: '$time${location != null ? ' - $location' : ''}',
      date: DateTime.tryParse(date) ?? createdAt,
      content: description ?? name,
      isPinned: false,
    );
  }
}
