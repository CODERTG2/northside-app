// lib/models/general_event.dart
import '../core/utils/logger.dart';

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
        AppLogger.warning('Error parsing createdAt: $e');
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
      subtitle: _buildArticleSubtitle(),
      content: description ?? '$name at $time${location != null ? ' in $location' : ''}.',
    );
  }

  // Helper method to build article subtitle based on event date
  String _buildArticleSubtitle() {
    try {
      final eventDate = _parseEventDateForArticle();
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final eventDay = DateTime(eventDate.year, eventDate.month, eventDate.day);
      
      // If it's today, show time and location
      if (eventDay.isAtSameMomentAs(today)) {
        return '$time${location != null ? ' - $location' : ''}';
      }
      
      // If it's in the future, show days away and location
      final daysDifference = eventDay.difference(today).inDays;
      if (daysDifference > 0) {
        final daysText = daysDifference == 1 ? '1 day away' : '$daysDifference days away';
        return '$daysText${location != null ? ' - $location' : ''}';
      }
      
      // If it's in the past, show time (fallback)
      return '$time${location != null ? ' - $location' : ''}';
    } catch (e) {
      // If date parsing fails, fallback to time and location
      return '$time${location != null ? ' - $location' : ''}';
    }
  }

  // Helper method to parse event date for articles
  DateTime _parseEventDateForArticle() {
    if (date.isEmpty) return createdAt;
    
    try {
      // Try to parse formats like "1/4/2025", "2/28/2025", etc.
      final parts = date.split('/');
      if (parts.length == 3) {
        final month = int.tryParse(parts[0]) ?? 1;
        int day = int.tryParse(parts[1]) ?? 1;
        int year = int.tryParse(parts[2]) ?? DateTime.now().year;
        
        // Validate ranges
        if (month < 1 || month > 12) {
          return createdAt;
        }
        if (day < 1) day = 1;
        if (day > 31) day = 31;
        
        return DateTime(year, month, day);
      }
      
      // Fallback to trying DateTime.parse
      return DateTime.parse(date);
    } catch (e) {
      return createdAt;
    }
  }

  // Convert to BulletinPost for bulletin display
  BulletinPost toBulletinPost() {
    DateTime parseEventDate() {
      try {
        // Handle various date formats from API
        if (date.isEmpty) return createdAt;
        
        // Try to parse formats like "1/4/2025", "2/28/2025", etc.
        // Note: Backend now uses standard 1-12 month format
        final parts = date.split('/');
        if (parts.length == 3) {
          final month = int.tryParse(parts[0]) ?? 1;
          int day = int.tryParse(parts[1]) ?? 1;
          int year = int.tryParse(parts[2]) ?? DateTime.now().year;
          
          // Validate ranges
          if (month < 1 || month > 12) {
            AppLogger.warning('Invalid month in date: $date');
            return createdAt;
          }
          if (day < 1) day = 1;
          if (day > 31) day = 31;
          
          return DateTime(year, month, day);
        }
        
        // Fallback to trying DateTime.parse
        return DateTime.parse(date);
      } catch (e) {
        AppLogger.warning('Error parsing event date "$date": $e');
        return createdAt;
      }
    }

    return BulletinPost(
      title: name,
      subtitle: _buildSubtitle(parseEventDate()),
      date: parseEventDate(),
      content: description ?? name,
      imagePath: 'assets/images/flexes_icon.png', // Default image for events
      isPinned: false,
    );
  }

  // Helper method to build subtitle based on event date
  String _buildSubtitle(DateTime eventDate) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final eventDay = DateTime(eventDate.year, eventDate.month, eventDate.day);
    
    // If it's today, show time
    if (eventDay.isAtSameMomentAs(today)) {
      return '$time${location != null ? ' - $location' : ''}';
    }
    
    // If it's in the future, show days away
    final daysDifference = eventDay.difference(today).inDays;
    if (daysDifference > 0) {
      final daysText = daysDifference == 1 ? '1 day away' : '$daysDifference days away';
      return '$daysText${location != null ? ' - $location' : ''}';
    }
    
    // If it's in the past, show time (fallback)
    return '$time${location != null ? ' - $location' : ''}';
  }
}
