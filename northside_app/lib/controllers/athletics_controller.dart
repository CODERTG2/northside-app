// lib/controllers/athletics_controller.dart

import 'package:get/get.dart';
import '../models/athlete.dart';
import '../models/athletics_schedule.dart';
import '../models/article.dart';
import '../api.dart';

class AthleticsController extends GetxController {
  // Observable lists for real data
  final RxList<Athlete> athletes = <Athlete>[].obs;
  final RxList<AthleticsSchedule> schedule = <AthleticsSchedule>[].obs;
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadData();
  }

  // Load all athletics data
  Future<void> loadData() async {
    isLoading.value = true;
    error.value = '';
    
    try {
      await Future.wait([
        loadAthletes(),
        loadSchedule(),
      ]);
    } catch (e) {
      error.value = 'Failed to load athletics data: $e';
      print('Error loading athletics data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Load athletes/roster from API
  Future<void> loadAthletes() async {
    try {
      final fetchedAthletes = await ApiService.fetchRoster();
      athletes.assignAll(fetchedAthletes);
    } catch (e) {
      print('Error loading athletes: $e');
    }
  }

  // Load athletics schedule from API
  Future<void> loadSchedule() async {
    try {
      final fetchedSchedule = await ApiService.fetchAthleticsSchedule();
      schedule.assignAll(fetchedSchedule);
    } catch (e) {
      print('Error loading athletics schedule: $e');
    }
  }

  // Get athletes by sport, gender, and level
  List<Athlete> getAthletesBySport({
    String? sport,
    String? gender,
    String? level,
  }) {
    return athletes.where((athlete) {
      bool matches = true;
      if (sport != null && athlete.sport.toLowerCase() != sport.toLowerCase()) {
        matches = false;
      }
      if (gender != null && athlete.gender.toLowerCase() != gender.toLowerCase()) {
        matches = false;
      }
      if (level != null && athlete.level.toLowerCase() != level.toLowerCase()) {
        matches = false;
      }
      return matches;
    }).toList();
  }

  // Get schedule by sport
  List<AthleticsSchedule> getScheduleBySport(String sport) {
    return schedule.where((event) => 
      event.sport.toLowerCase().contains(sport.toLowerCase())
    ).toList();
  }

  // Get recent athletics news (upcoming games as articles)
  List<Article> getAthleticsNews() {
    // Get upcoming games in the next 7 days
    final now = DateTime.now();
    final weekFromNow = now.add(const Duration(days: 7));
    
    final upcomingGames = schedule.where((event) {
      try {
        final eventDate = DateTime.parse(event.date);
        return eventDate.isAfter(now) && eventDate.isBefore(weekFromNow);
      } catch (e) {
        return false;
      }
    }).take(5).toList();

    return upcomingGames.map((game) => game.toArticle()).toList();
  }

  // Get athletics news from recent games and events
  List<Article> getRecentAthleticsNews() {
    final now = DateTime.now();
    final recentGames = schedule.where((game) {
      final gameDate = DateTime.tryParse(game.date);
      if (gameDate == null) return false;
      // Include games from the last 30 days and upcoming games
      return gameDate.isAfter(now.subtract(const Duration(days: 30)));
    }).toList();

    recentGames.sort((a, b) {
      final dateA = DateTime.tryParse(a.date);
      final dateB = DateTime.tryParse(b.date);
      if (dateA == null && dateB == null) return 0;
      if (dateA == null) return 1;
      if (dateB == null) return -1;
      return dateB.compareTo(dateA); // Most recent first
    });

    return recentGames.take(10).map((game) => game.toArticle()).toList();
  }

  // Get sports list from available data
  List<String> getAvailableSports() {
    final sports = athletes.map((athlete) => athlete.sport).toSet().toList();
    sports.sort();
    return sports;
  }

  // Get teams by sport (combines gender and level)
  List<String> getTeamsBySport(String sport) {
    final sportAthletes = getAthletesBySport(sport: sport);
    final teams = sportAthletes.map((athlete) => 
      '${athlete.gender.toUpperCase()} ${athlete.level.toUpperCase()}'
    ).toSet().toList();
    teams.sort();
    return teams;
  }

  // Refresh data
  Future<void> refreshData() async {
    await loadData();
  }
}
