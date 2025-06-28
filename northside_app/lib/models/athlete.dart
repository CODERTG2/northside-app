// lib/models/athlete.dart

// Import for Player class
import '../presentation/athletics/sport_detail_page.dart';

class Athlete {
  final String id;
  final String name;
  final String sport;
  final String level; // varsity, jv, freshman
  final String gender; // girls, boys
  final String grade; // Fr., So., Jr., Sr.
  final String position;
  final DateTime createdAt;

  const Athlete({
    required this.id,
    required this.name,
    required this.sport,
    required this.level,
    required this.gender,
    required this.grade,
    required this.position,
    required this.createdAt,
  });

  factory Athlete.fromJson(Map<String, dynamic> json) {
    return Athlete(
      id: json['\$oid'] ?? json['_id']?['\$oid'] ?? '',
      name: json['name'] ?? '',
      sport: json['sport'] ?? '',
      level: json['level'] ?? '',
      gender: json['gender'] ?? '',
      grade: json['grade'] ?? '',
      position: json['position'] ?? '',
      createdAt: DateTime.parse(json['createdAt']?['\$date'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'sport': sport,
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
      number: '', // This field doesn't exist in your backend model
      position: position,
      grade: grade,
    );
  }
}
