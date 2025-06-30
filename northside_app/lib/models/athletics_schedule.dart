// lib/models/athletics_schedule.dart
import '../core/utils/logger.dart';

import '../presentation/athletics/sport_detail_page.dart';
import 'article.dart';
import 'bulletin_post.dart';

class AthleticsSchedule {
  final String id;
  final String date;
  final String time;
  final String sport;
  final String gender;
  final String level;
  final String opponent;
  final String location;
  final bool home;
  final DateTime createdAt;

  const AthleticsSchedule({
    required this.id,
    required this.date,
    required this.time,
    required this.sport,
    required this.gender,
    required this.level,
    required this.opponent,
    required this.location,
    required this.home,
    required this.createdAt,
  });

  factory AthleticsSchedule.fromJson(Map<String, dynamic> json) {
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

    return AthleticsSchedule(
      id: json['\$oid'] ?? json['_id']?['\$oid'] ?? '',
      date: (json['date'] ?? '').toString(),
      time: (json['time'] ?? '').toString(),
      sport: (json['sport'] ?? '').toString(),
      gender: (json['gender'] ?? '').toString(),
      level: (json['level'] ?? '').toString(),
      opponent: (json['opponent'] ?? '').toString(),
      location: (json['location'] ?? '').toString(),
      home: json['home'] ?? false,
      createdAt: parseCreatedAt(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'time': time,
      'sport': sport,
      'gender': gender,
      'level': level,
      'opponent': opponent,
      'location': location,
      'home': home,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // Convert to GameSchedule for UI compatibility (sport_detail_page.dart)
  GameSchedule toGameSchedule() {
    // Create a team name from gender and level
    final teamName = '${gender.toUpperCase()} ${level.toUpperCase()}';
    return GameSchedule(
      date: date,
      time: time,
      event: teamName,
      opponent: opponent,
      location: location,
      score: '', // Score not available in schedule, only for completed games
      result: '', // Result not available in schedule, only for completed games
    );
  }

  // Convert to Article for events display
  Article toArticle() {
    final homeAway = home ? 'vs' : 'at';
    final teamName = '${gender.toUpperCase()} ${level.toUpperCase()}';
    return Article(
      title: '$sport $homeAway $opponent',
      subtitle: _buildArticleSubtitle(),
      content: '$teamName $homeAway $opponent at $location on $date at $time.',
      imagePath: 'assets/images/flexes_icon.png', // Add image for athletics games
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
        return '$time - $location';
      }
      
      // If it's in the future, show days away and location
      final daysDifference = eventDay.difference(today).inDays;
      if (daysDifference > 0) {
        final daysText = daysDifference == 1 ? '1 day away' : '$daysDifference days away';
        return '$daysText - $location';
      }
      
      // If it's in the past, show time (fallback)
      return '$time - $location';
    } catch (e) {
      // If date parsing fails, fallback to time and location
      return '$time - $location';
    }
  }

  // Helper method to parse event date for articles
  DateTime _parseEventDateForArticle() {
    if (date.isEmpty) return createdAt;

    try {
      // Try to parse formats like "6/27/2025"
      if (date.contains('/')) {
        final parts = date.split('/');
        if (parts.length == 3) {
          final month = int.tryParse(parts[0]) ?? 1;
          final day = int.tryParse(parts[1]) ?? 1;
          final year = int.tryParse(parts[2]) ?? DateTime.now().year;
          return DateTime(year, month, day);
        }
      }

      // Try parsing "Aug 26 2025" format
      if (date.contains(' ') && !date.contains('/') && !date.contains('-')) {
        final parts = date.split(' ');
        if (parts.length == 3) {
          final monthStr = parts[0];
          final day = int.tryParse(parts[1]) ?? 1;
          final year = int.tryParse(parts[2]) ?? DateTime.now().year;
          
          final monthMap = {
            'Jan': 1, 'Feb': 2, 'Mar': 3, 'Apr': 4, 'May': 5, 'Jun': 6,
            'Jul': 7, 'Aug': 8, 'Sep': 9, 'Oct': 10, 'Nov': 11, 'Dec': 12
          };
          
          final month = monthMap[monthStr] ?? 1;
          return DateTime(year, month, day);
        }
      }

      return DateTime.parse(date);
    } catch (e) {
      return createdAt;
    }
  }

  // Convert to BulletinPost for bulletin display
  BulletinPost toBulletinPost() {
    DateTime parseEventDate() {
      try {
        if (date.isEmpty) return createdAt;

        // Try to parse formats like "6/27/2025"
        if (date.contains('/')) {
          final parts = date.split('/');
          if (parts.length == 3) {
            final month = int.tryParse(parts[0]) ?? 1;
            int day = int.tryParse(parts[1]) ?? 1;
            int year = int.tryParse(parts[2]) ?? DateTime.now().year;

            // Validate ranges (now using standard 1-12 format)
            if (month < 1 || month > 12) {
              AppLogger.warning('Invalid month in athletics date: $date');
              return createdAt;
            }
            if (day < 1) day = 1;
            if (day > 31) day = 31;

            return DateTime(year, month, day);
          }
        }

        // Try parsing "Aug 26 2025" format (athletics schedule format)
        if (date.contains(' ') && !date.contains('/') && !date.contains('-')) {
          final parts = date.split(' ');
          if (parts.length == 3) {
            final monthStr = parts[0];
            final day = int.tryParse(parts[1]) ?? 1;
            final year = int.tryParse(parts[2]) ?? DateTime.now().year;
            
            // Map month abbreviations to numbers
            final monthMap = {
              'Jan': 1, 'Feb': 2, 'Mar': 3, 'Apr': 4, 'May': 5, 'Jun': 6,
              'Jul': 7, 'Aug': 8, 'Sep': 9, 'Oct': 10, 'Nov': 11, 'Dec': 12
            };
            
            final month = monthMap[monthStr] ?? 1;
            return DateTime(year, month, day);
          }
        }

        // Fallback to trying DateTime.parse
        return DateTime.parse(date);
      } catch (e) {
        AppLogger.warning('Error parsing athletics schedule date "$date": $e');
        return createdAt;
      }
    }

    return BulletinPost(
      title: '$sport ${home ? "vs" : "at"} $opponent',
      subtitle: _buildSubtitle(parseEventDate()),
      date: parseEventDate(),
      content: '${gender.toUpperCase()} ${level.toUpperCase()} ${home ? "vs" : "at"} $opponent at $location on $date at $time.',
      imagePath: 'assets/images/flexes_icon.png', // Default image for athletics
      isPinned: false,
    );
  }

  // Helper method to build subtitle based on event date
  String _buildSubtitle(DateTime eventDate) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final eventDay = DateTime(eventDate.year, eventDate.month, eventDate.day);
    
    // If it's today, show time and location
    if (eventDay.isAtSameMomentAs(today)) {
      return '$time - $location';
    }
    
    // If it's in the future, show days away and location
    final daysDifference = eventDay.difference(today).inDays;
    if (daysDifference > 0) {
      final daysText = daysDifference == 1 ? '1 day away' : '$daysDifference days away';
      return '$daysText - $location';
    }
    
    // If it's in the past, show time (fallback)
    return '$time - $location';
  }
}
