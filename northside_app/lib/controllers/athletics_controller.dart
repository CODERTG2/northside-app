// lib/controllers/athletics_controller.dart

import 'package:get/get.dart';
import '../models/athlete.dart';
import '../models/athletics_schedule.dart';
import '../models/article.dart';
import '../api.dart';
import '../core/utils/logger.dart';

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
      AppLogger.error('Error loading athletics data', e);
    } finally {
      isLoading.value = false;
    }
  }

  // Load athletes/roster from API
  Future<void> loadAthletes() async {
    try {
      final fetchedAthletes = await ApiService.getRoster();
      athletes.assignAll(fetchedAthletes);
    } catch (e) {
      AppLogger.error('Error loading athletes', e);
    }
  }

  // Load athletics schedule from API
  Future<void> loadSchedule() async {
    try {
      final fetchedSchedule = await ApiService.getAthleticsSchedule();
      schedule.assignAll(fetchedSchedule);
      AppLogger.info('Loaded ${schedule.length} athletics schedule items');
      // Debug: log first few items
      if (schedule.isNotEmpty) {
        for (int i = 0; i < schedule.length && i < 3; i++) {
          AppLogger.debug('Athletics Schedule $i: ${schedule[i].date} - ${schedule[i].sport} - ${schedule[i].opponent}');
        }
      }
    } catch (e) {
      AppLogger.error('Error loading athletics schedule', e);
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
    // IMPORTANT: Let's see what exactly is being passed as the sport parameter
    AppLogger.debug('=== SCHEDULE FILTERING DEBUG ===');
    AppLogger.debug('Input sport parameter: "$sport"');
    
    // Extract gender prefix from sport name
    String? genderFilter;
    String actualSport = sport;
    
    if (sport.startsWith("Men's ")) {
      genderFilter = 'boys';
      actualSport = sport.substring(6);
      AppLogger.debug('Detected Men\'s sport - genderFilter: $genderFilter, actualSport: $actualSport');
    } else if (sport.startsWith("Women's ")) {
      genderFilter = 'girls';
      actualSport = sport.substring(8);
      AppLogger.debug('Detected Women\'s sport - genderFilter: $genderFilter, actualSport: $actualSport');
    } else {
      AppLogger.debug('No gender prefix detected in sport name');
    }
    
    AppLogger.debug('Total schedule items: ${schedule.length}');
    
    // Debug: Log some sample data to understand the format
    if (schedule.isNotEmpty) {
      for (int i = 0; i < schedule.length && i < 5; i++) {
        AppLogger.debug('Sample data [$i]: sport="${schedule[i].sport}", gender="${schedule[i].gender}", level="${schedule[i].level}", opponent="${schedule[i].opponent}"');
      }
    }
    
    final filteredSchedule = schedule.where((event) {
      // Check if the sport matches
      bool sportMatches = event.sport.toLowerCase().contains(actualSport.toLowerCase());
      
      // If no gender filter, return all matches for the sport
      if (genderFilter == null) {
        AppLogger.debug('No gender filter, sportMatches: $sportMatches for ${event.sport}');
        return sportMatches;
      }
      
      // Check if the gender matches directly
      bool genderMatches = false;
      String eventGenderLower = event.gender.toLowerCase();
      
      if (genderFilter == 'boys') {
        genderMatches = eventGenderLower == 'boys' || 
                       eventGenderLower == 'men' || 
                       eventGenderLower == 'male' ||
                       eventGenderLower == 'm';
      } else if (genderFilter == 'girls') {
        genderMatches = eventGenderLower == 'girls' || 
                       eventGenderLower == 'women' || 
                       eventGenderLower == 'female' ||
                       eventGenderLower == 'w';
      }
      
      // Debug logging for each filter attempt
      if (sportMatches) {
        AppLogger.debug('Event: ${event.sport} ${event.gender} ${event.level}, sportMatches: $sportMatches, genderMatches: $genderMatches, eventGender: "${event.gender}"');
      }
      
      return sportMatches && genderMatches;
    }).toList();
    
    AppLogger.debug('Filtered schedule: found ${filteredSchedule.length} games for $sport');
    
    // Debug: Show what we're returning
    if (filteredSchedule.isNotEmpty) {
      for (int i = 0; i < filteredSchedule.length && i < 3; i++) {
        AppLogger.debug('Returning game [$i]: ${filteredSchedule[i].sport} ${filteredSchedule[i].gender} ${filteredSchedule[i].level} vs ${filteredSchedule[i].opponent}');
      }
    }
    
    return filteredSchedule;
  }

  // Get schedule by sport, gender, and level (more specific filtering)
  List<AthleticsSchedule> getScheduleByFilters({
    String? sport,
    String? gender,
    String? level,
  }) {
    AppLogger.debug('Filtering schedule with: sport=$sport, gender=$gender, level=$level');
    
    final filteredSchedule = schedule.where((event) {
      bool matches = true;
      
      if (sport != null && !event.sport.toLowerCase().contains(sport.toLowerCase())) {
        matches = false;
      }
      
      if (gender != null) {
        String eventGenderLower = event.gender.toLowerCase();
        String genderLower = gender.toLowerCase();
        
        // Handle different gender representations
        bool genderMatches = false;
        if (genderLower == 'boys' || genderLower == 'men' || genderLower == 'male') {
          genderMatches = eventGenderLower == 'boys' || 
                         eventGenderLower == 'men' || 
                         eventGenderLower == 'male' ||
                         eventGenderLower == 'm';
        } else if (genderLower == 'girls' || genderLower == 'women' || genderLower == 'female') {
          genderMatches = eventGenderLower == 'girls' || 
                         eventGenderLower == 'women' || 
                         eventGenderLower == 'female' ||
                         eventGenderLower == 'w';
        }
        
        if (!genderMatches) {
          matches = false;
        }
      }
      
      if (level != null && !event.level.toLowerCase().contains(level.toLowerCase())) {
        matches = false;
      }
      
      return matches;
    }).toList();
    
    AppLogger.debug('Filtered schedule: found ${filteredSchedule.length} games');
    return filteredSchedule;
  }

  // Get recent athletics news (upcoming games as articles)
  List<Article> getAthleticsNews() {
    // Get all upcoming games (future games only)
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    final upcomingGames = schedule.where((event) {
      try {
        final eventDate = _parseEventDate(event.date);
        // Include games that are today or in the future
        return eventDate != null && !eventDate.isBefore(today);
      } catch (e) {
        return false;
      }
    }).toList();

    // Sort by date (earliest first)
    upcomingGames.sort((a, b) {
      final dateA = _parseEventDate(a.date);
      final dateB = _parseEventDate(b.date);
      if (dateA == null && dateB == null) return 0;
      if (dateA == null) return 1;
      if (dateB == null) return -1;
      return dateA.compareTo(dateB);
    });

    // Return articles from real data (take first 10 upcoming games)
    return upcomingGames.take(10).map((game) => game.toArticle()).toList();
  }

  // Helper method to parse various date formats
  DateTime? _parseEventDate(String dateString) {
    if (dateString.isEmpty) return null;
    
    try {
      // Try parsing M/D/YYYY format first (most common in our data)
      if (dateString.contains('/')) {
        final parts = dateString.split('/');
        if (parts.length == 3) {
          final month = int.tryParse(parts[0]) ?? 1;
          final day = int.tryParse(parts[1]) ?? 1;
          final year = int.tryParse(parts[2]) ?? DateTime.now().year;
          return DateTime(year, month, day);
        }
      }
      
      // Try parsing "Aug 26 2025" format (athletics schedule format)
      if (dateString.contains(' ') && !dateString.contains('/') && !dateString.contains('-')) {
        final parts = dateString.split(' ');
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
      
      // Try parsing ISO format (YYYY-MM-DD)
      return DateTime.parse(dateString);
    } catch (e) {
      AppLogger.warning('Error parsing date: $dateString', e);
      return null;
    }
  }

  // Get athletics news from recent games and events
  List<Article> getRecentAthleticsNews() {
    final now = DateTime.now();
    final recentGames = schedule.where((game) {
      final gameDate = _parseEventDate(game.date);
      if (gameDate == null) return false;
      // Include games from the last 30 days and upcoming games
      return gameDate.isAfter(now.subtract(const Duration(days: 30)));
    }).toList();

    recentGames.sort((a, b) {
      final dateA = _parseEventDate(a.date);
      final dateB = _parseEventDate(b.date);
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
