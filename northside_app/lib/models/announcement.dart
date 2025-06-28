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

    return Announcement(
      id: json['_id']?['\$oid'] ?? json['\$oid'] ?? json['_id']?.toString() ?? '',
      date: json['date'] ?? '',
      title: json['title'] ?? '',
      description: json['description'],
      createdBy: json['createdBy'] ?? '',
      createdAt: parseCreatedAt(),
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
    DateTime parseAnnouncementDate() {
      try {
        if (date.isEmpty) return createdAt;
        
        // Try to parse formats like "6/27/2025"
        final parts = date.split('/');
        if (parts.length == 3) {
          int month = int.tryParse(parts[0]) ?? 1;
          int day = int.tryParse(parts[1]) ?? 1;
          int year = int.tryParse(parts[2]) ?? DateTime.now().year;
          
          // Validate ranges
          if (month > 12) month = 12;
          if (month < 1) month = 1;
          if (day < 1) day = 1;
          if (day > 31) day = 31;
          
          return DateTime(year, month, day);
        }
        
        // Fallback to trying DateTime.parse
        return DateTime.parse(date);
      } catch (e) {
        print('Error parsing announcement date "$date": $e');
        return createdAt;
      }
    }

    return BulletinPost(
      title: title,
      subtitle: description ?? 'Posted by $createdBy',
      date: parseAnnouncementDate(),
      content: description ?? title,
      isPinned: false,
    );
  }
}
