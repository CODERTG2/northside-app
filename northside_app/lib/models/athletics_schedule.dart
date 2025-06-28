// lib/models/athletics_schedule.dart

import '../presentation/athletics/sport_detail_page.dart';
import 'article.dart';
import 'bulletin_post.dart';

class AthleticsSchedule {
  final String id;
  final String date;
  final String time;
  final String sport;
  final String team;
  final String opponent;
  final String location;
  final bool home;
  final DateTime createdAt;

  const AthleticsSchedule({
    required this.id,
    required this.date,
    required this.time,
    required this.sport,
    required this.team,
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
        print('Error parsing createdAt: $e');
        return DateTime.now();
      }
    }

    return AthleticsSchedule(
      id: json['\$oid'] ?? json['_id']?['\$oid'] ?? '',
      date: (json['date'] ?? '').toString(),
      time: (json['time'] ?? '').toString(),
      sport: (json['sport'] ?? '').toString(),
      team: (json['team'] ?? '').toString(),
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
      'team': team,
      'opponent': opponent,
      'location': location,
      'home': home,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // Convert to GameSchedule for UI compatibility (sport_detail_page.dart)
  GameSchedule toGameSchedule() {
    return GameSchedule(
      date: date,
      time: time,
      event: team,
      opponent: opponent,
      location: location,
      score: '', // Score not available in schedule, only for completed games
      result: '', // Result not available in schedule, only for completed games
    );
  }

  // Convert to Article for events display
  Article toArticle() {
    final homeAway = home ? 'vs' : 'at';
    return Article(
      title: '$sport Game $homeAway $opponent',
      subtitle: '$time - $location',
      content: '$team $homeAway $opponent at $location on $date at $time.',
    );
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
            int month = int.tryParse(parts[0]) ?? 1;
            int day = int.tryParse(parts[1]) ?? 1;
            int year = int.tryParse(parts[2]) ?? DateTime.now().year;

            // Handle 0-based month indexing from backend scraper (0 = January, 11 = December)
            if (month >= 0 && month <= 11) {
              month = month + 1; // Convert 0-11 to 1-12
            }

            // Validate ranges
            if (month < 1 || month > 12) month = 1;
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
        print('Error parsing athletics schedule date "$date": $e');
        return createdAt;
      }
    }

    return BulletinPost(
      title: '$sport Game',
      subtitle: '$time ${home ? "vs" : "at"} $opponent',
      date: parseEventDate(),
      content: '$team ${home ? "vs" : "at"} $opponent at $location on $date at $time.',
      imagePath: 'assets/images/flexes_icon.png', // Default image for athletics
      isPinned: false,
    );
  }
}
