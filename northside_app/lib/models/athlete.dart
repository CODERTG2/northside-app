// lib/models/athlete.dart

// Import for Player class
import '../presentation/athletics/sport_detail_page.dart';
import '../core/utils/logger.dart';

class Athlete {
  final String id;
  final String name;
  final int number;
  final String sport;
  final String season; // fall, winter, spring
  final String level; // varsity, jv, freshman
  final String gender; // girls, boys
  final String grade; // Fr., So., Jr., Sr.
  final String position;
  final DateTime createdAt;

  const Athlete({
    required this.id,
    required this.name,
    required this.number,
    required this.sport,
    required this.season,
    required this.level,
    required this.gender,
    required this.grade,
    required this.position,
    required this.createdAt,
  });

  factory Athlete.fromJson(Map<String, dynamic> json) {
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
        AppLogger.warning('Error parsing createdAt', e);
        return DateTime.now();
      }
    }

    return Athlete(
      id: json['\$oid'] ?? json['_id']?['\$oid'] ?? '',
      name: json['name'] ?? '',
      number: json['number'] ?? 0,
      sport: json['sport'] ?? '',
      season: json['season'] ?? '',
      level: json['level'] ?? '',
      gender: json['gender'] ?? '',
      grade: json['grade'] ?? '',
      position: json['position'] ?? '',
      createdAt: parseCreatedAt(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'number': number,
      'sport': sport,
      'season': season,
      'level': level,
      'gender': gender,
      'grade': grade,
      'position': position,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // Convert to Player for UI compatibility (sport_detail_page.dart)
  Player toPlayer() {
    return Player(
      name: name,
      number: number == 0 ? '' : number.toString(),
      position: position,
      grade: grade,
    );
  }
}
