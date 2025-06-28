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
    DateTime parseCreatedAt() {
      try {
        final createdAtField = json['createdAt'];
        if (createdAtField is Map && createdAtField.containsKey('\$date')) {
          // MongoDB timestamp format: {"$date": 1751022383799}
          final timestamp = createdAtField['\$date'];
          if (timestamp is int) {
            return DateTime.fromMillisecondsSinceEpoch(timestamp);
          }
        } else if (createdAtField is String) {
          // String format
          return DateTime.parse(createdAtField);
        }
        return DateTime.now();
      } catch (e) {
        print('Error parsing createdAt: $e');
        return DateTime.now();
      }
    }

    return GeneralEvent(
      id: json['_id']?['\$oid'] ?? json['\$oid'] ?? json['_id']?.toString() ?? '',
      date: json['date'] ?? '',
      time: json['time'] ?? '',
      name: json['name'] ?? '',
      description: json['description'],
      location: json['location'],
      createdBy: json['createdBy'] ?? '',
      createdAt: parseCreatedAt(),
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
    DateTime parseEventDate() {
      try {
        // Handle various date formats from API
        if (date.isEmpty) return createdAt;
        
        // Try to parse formats like "1/4/2025", "2/28/2025", etc.
        // Note: API sometimes returns "0/1/2025" which is invalid, so we need to handle this
        final parts = date.split('/');
        if (parts.length == 3) {
          int month = int.tryParse(parts[0]) ?? 1;
          int day = int.tryParse(parts[1]) ?? 1;
          int year = int.tryParse(parts[2]) ?? DateTime.now().year;
          
          // Fix invalid month "0" to "12" (December)
          if (month == 0) month = 12;
          
          // Validate ranges
          if (month > 12) month = 12;
          if (day < 1) day = 1;
          if (day > 31) day = 31;
          
          return DateTime(year, month, day);
        }
        
        // Fallback to trying DateTime.parse
        return DateTime.parse(date);
      } catch (e) {
        print('Error parsing event date "$date": $e');
        return createdAt;
      }
    }

    return BulletinPost(
      title: name,
      subtitle: '$time${location != null ? ' - $location' : ''}',
      date: parseEventDate(),
      content: description ?? name,
      isPinned: false,
    );
  }
}
