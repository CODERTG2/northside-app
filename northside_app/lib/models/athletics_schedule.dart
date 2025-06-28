// lib/models/athletics_schedule.dart

import '../presentation/athletics/sport_detail_page.dart';
import 'article.dart';

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
    return AthleticsSchedule(
      id: json['\$oid'] ?? json['_id']?['\$oid'] ?? '',
      date: json['date'] ?? '',
      time: json['time'] ?? '',
      sport: json['sport'] ?? '',
      team: json['team'] ?? '',
      opponent: json['opponent'] ?? '',
      location: json['location'] ?? '',
      home: json['home'] ?? false,
      createdAt: DateTime.parse(json['createdAt']?['\$date'] ?? DateTime.now().toIso8601String()),
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
}
