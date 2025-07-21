// lib/controllers/athletics_controller.dart

import 'package:get/get.dart';
import '../models/athlete.dart';
import '../models/athletics_schedule.dart';
import '../models/article.dart';
import '../services/api_service.dart';
import '../core/utils/logger.dart';


  final ApiService _apiService = ApiService();
  final RxList<Athlete> athletes = <Athlete>[].obs;
  final RxList<AthleticsSchedule> schedule = <AthleticsSchedule>[].obs;
  final RxList<SportEntry> sports = <SportEntry>[].obs;
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchSports();
  }

  void fetchSports() async {
    try {
      isLoading(true);
      var result = await _apiService.fetchSportsData();
      sports.assignAll(result);
    } catch (e) {
      error.value = 'Failed to load sports data: $e';
      AppLogger.error('Error loading sports data', e);
    } finally {
      isLoading(false);
    }
  }

  // Load fresh data from API for a specific sport and gender
  // This is useful when opening a team-specific page to ensure latest data
  Future<Map<String, dynamic>> loadTeamData({
    required String sport,
    String? gender,
    String? level,
  }) async {
    try {
      AppLogger.debug('Loading fresh team data for sport: $sport, gender: $gender, level: $level');
      
      // Load fresh roster data from API
      // TODO: Replace with new ApiService instance methods when available
      // For now, fallback to controller state
      AppLogger.debug('Loaded fresh team data from controller state (API methods not yet implemented)');
      return {
        'roster': getAthletesBySport(sport: sport, gender: gender, level: level),
        'schedule': getScheduleByFilters(sport: sport, gender: gender, level: level),
      };
    } catch (e) {
      AppLogger.error('Error loading fresh team data', e);
      // Fallback to existing data
      return {
        'roster': getAthletesBySport(sport: sport, gender: gender, level: level),
        'schedule': getScheduleByFilters(sport: sport, gender: gender, level: level),
      };
    }
  }

  // Get athletes by sport, gender, and level
  List<Athlete> getAthletesBySport({
    String? sport,
    String? gender,
    String? level,
  }) {
    // Debug logging for flag football specifically
    if (sport != null && sport.toLowerCase().contains('flag')) {
      print('=== DEBUG: Filtering athletes for flag football: "$sport"');
      print('=== DEBUG: Total athletes to search: ${athletes.length}');
    }
    
    return athletes.where((athlete) {
      bool matches = true;
      
      if (sport != null) {
        final normalizedSport = _normalizeSportName(sport);
        final normalizedAthleteSport = _normalizeSportName(athlete.sport);
        
        // Debug logging for flag football
        if (sport.toLowerCase().contains('flag')) {
          print('=== DEBUG: Checking athlete "${athlete.name}" - sport: "${athlete.sport}" (normalized: "$normalizedAthleteSport") vs search: "$normalizedSport"');
        }
        
        matches = normalizedAthleteSport.contains(normalizedSport) || 
                  normalizedSport.contains(normalizedAthleteSport);
                  
        // Debug logging for flag football
        if (sport.toLowerCase().contains('flag') && matches) {
          print('=== DEBUG: MATCH FOUND for flag football athlete: "${athlete.name}" - ${athlete.sport} (${athlete.gender})');
        }
      }
      
      if (gender != null && matches) {
        final normalizedGender = _normalizeGender(gender);
        final normalizedAthleteGender = _normalizeGender(athlete.gender);
        matches = normalizedAthleteGender == normalizedGender;
        
        // Debug logging for flag football
        if (sport != null && sport.toLowerCase().contains('flag')) {
          print('=== DEBUG: Gender filter for flag football - athlete gender: "${athlete.gender}" (normalized: "$normalizedAthleteGender") vs search: "$normalizedGender" - matches: $matches');
        }
      }
      
      if (level != null && matches) {
        matches = athlete.level.toLowerCase() == level.toLowerCase();
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
    
    if (sport.startsWith("Boys ")) {
      genderFilter = 'boys';
      actualSport = sport.substring(5);
      AppLogger.debug('Detected Boys\' sport - genderFilter: $genderFilter, actualSport: $actualSport');
    } else if (sport.startsWith("Girls ")) {
      genderFilter = 'girls';
      actualSport = sport.substring(6);
      AppLogger.debug('Detected Girls\' sport - genderFilter: $genderFilter, actualSport: $actualSport');
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
  // This method can optionally use API calls for real-time filtering
  List<AthleticsSchedule> getScheduleByFilters({
    String? sport,
    String? gender,
    String? level,
  }) {
    AppLogger.debug('Filtering schedule with: sport=$sport, gender=$gender, level=$level');
    
    final filteredSchedule = schedule.where((event) {
      bool matches = true;
      
      if (sport != null) {
        final normalizedSport = _normalizeSportName(sport);
        final normalizedEventSport = _normalizeSportName(event.sport);
        matches = normalizedEventSport.contains(normalizedSport) || 
                 normalizedSport.contains(normalizedEventSport);
      }
      
      if (gender != null && matches) {
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
      
      if (level != null && matches) {
        String eventLevelLower = event.level.toLowerCase();
        String levelLower = level.toLowerCase();
        
        // Handle level matching with JV variations
        bool levelMatches = false;
        if (levelLower == 'jv' || levelLower == 'junior varsity') {
          levelMatches = eventLevelLower == 'jv' || eventLevelLower == 'junior varsity';
        } else {
          levelMatches = eventLevelLower.contains(levelLower);
        }
        
        if (!levelMatches) {
          matches = false;
        }
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

    // Remove exact duplicates using a more specific key
    final seen = <String>{};
    final uniqueGames = <AthleticsSchedule>[];
    
    for (final game in upcomingGames) {
      final gameKey = '${game.sport}_${game.opponent}_${game.location}_${game.date}_${game.time}';
      if (!seen.contains(gameKey)) {
        seen.add(gameKey);
        uniqueGames.add(game);
      }
    }

    // Sort by date (earliest first)
    uniqueGames.sort((a, b) {
      final dateA = _parseEventDate(a.date);
      final dateB = _parseEventDate(b.date);
      if (dateA == null && dateB == null) return 0;
      if (dateA == null) return 1;
      if (dateB == null) return -1;
      return dateA.compareTo(dateB);
    });

    // Return articles from real data (take first 10 upcoming games)
    return uniqueGames.take(10).map((game) => game.toArticle()).toList();
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
      if (dateString.contains(' ')) {
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

  // Get unique sports from both athletes and schedule data
  List<String> getAllAvailableSports() {
    print('=== DEBUG: getAllAvailableSports called');
    print('=== DEBUG: Athletes count: ${athletes.length}');
    print('=== DEBUG: Schedule count: ${schedule.length}');
    
    final sportsSet = <String>{};
    
    // Add sports from athletes
    for (final athlete in athletes) {
      final normalizedSport = _normalizeSportName(athlete.sport);
      if (normalizedSport.isNotEmpty) {
        sportsSet.add(athlete.sport); // Keep original case for display
        print('=== DEBUG: Added sport from athletes: "${athlete.sport}"');
      }
    }
    
    // Add sports from schedule
    for (final event in schedule) {
      final normalizedSport = _normalizeSportName(event.sport);
      if (normalizedSport.isNotEmpty) {
        sportsSet.add(event.sport); // Keep original case for display
        print('=== DEBUG: Added sport from schedule: "${event.sport}"');
      }
    }
    
    print('=== DEBUG: Raw sports set (${sportsSet.length}): $sportsSet');
    
    // Convert to list and remove duplicates based on normalized names
    final sportsMap = <String, String>{}; // normalized -> original
    for (final sport in sportsSet) {
      final normalized = _normalizeSportName(sport);
      // Only keep the first occurrence of each normalized sport name
      if (!sportsMap.containsKey(normalized)) {
        sportsMap[normalized] = sport;
        print('=== DEBUG: Keeping sport: "$sport" (normalized: "$normalized")');
      } else {
        print('=== DEBUG: Skipping duplicate sport: "$sport" (normalized: "$normalized")');
      }
    }
    
    final sports = sportsMap.values.toList();
    sports.sort();
    print('=== DEBUG: Final sports list (${sports.length}): $sports');
    return sports;
  }

  // Get all available sports and organize them by season based ONLY on backend data
  // Get all available sports and organize them by season based ONLY on backend data
  List<String> getSportsBySeason(String season) {
    final seasonLower = season.toLowerCase();
    print('=== DEBUG: getSportsBySeason called for season: "$season" (lowercase: "$seasonLower")');
    print('=== DEBUG: Total athletes loaded: ${athletes.length}');
    
    // Check what seasons we have in the backend data
    final availableSeasons = athletes.map((a) => a.season).where((s) => s.isNotEmpty).toSet();
    print('=== DEBUG: Available seasons in backend: $availableSeasons');
    
    // Debug: Check if backend has proper season data
    if (availableSeasons.isEmpty) {
      print('=== WARNING: No season data found in backend! Showing ALL sports instead of filtering by season.');
      print('=== DEBUG: This ensures all sports are visible even when backend season data is missing.');
      // Return ALL sports when backend season data is missing - never hide sports
      return getAllAvailableSports();
    }
    
    // Show what sports are available for each season in the backend
    for (final backendSeason in availableSeasons) {
      final sportsInSeason = athletes.where((a) => a.season.toLowerCase() == backendSeason.toLowerCase()).map((a) => a.sport).toSet();
      print('=== DEBUG: Backend $backendSeason season has ${sportsInSeason.length} sports: $sportsInSeason');
    }
    
    final seasonSports = <String>{};
    
    // ONLY USE BACKEND SEASON DATA - NO FALLBACK LOGIC WHATSOEVER
    print('=== DEBUG: Looking for sports in "$season" season from backend data...');
    for (final athlete in athletes) {
      if (athlete.season.isNotEmpty && 
          athlete.season.toLowerCase() == seasonLower &&
          athlete.sport.isNotEmpty) {
        seasonSports.add(athlete.sport);
        print('=== DEBUG: Added "${athlete.sport}" to $season (backend says: ${athlete.season})');
      }
    }
    
    print('=== DEBUG: Sports for season "$season" (BACKEND ONLY): $seasonSports');
    
    // If no sports found for this season, but backend has season data, show all sports
    // This ensures we never hide sports due to missing/incomplete backend season assignments
    if (seasonSports.isEmpty && availableSeasons.isNotEmpty) {
      print('=== WARNING: No sports found for $season season, but backend has season data.');
      print('=== DEBUG: Showing ALL sports to ensure nothing is hidden from users.');
      return getAllAvailableSports();
    }
    
    // Normalize and deduplicate (preserve all backend sports)
    final normalizedSports = <String, String>{}; // normalized -> original
    for (final sport in seasonSports) {
      final normalized = _normalizeSportName(sport);
      if (!normalizedSports.containsKey(normalized)) {
        normalizedSports[normalized] = sport;
      }
    }
    
    final result = normalizedSports.values.toList();
    result.sort();
    print('=== DEBUG: Final sports for season "$season": $result');
    return result;
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

  // Helper method to normalize sport names for consistency
  String _normalizeSportName(String sport) {
    return sport.toLowerCase()
        .replaceAll('&', 'and')
        .replaceAll('16in', '')
        .replaceAll('16 in', '')
        .replaceAll('  ', ' ')
        .replaceAll('track and field', 'track & field') // Standardize track & field
        .replaceAll('cheer leading', 'cheerleading') // Standardize cheerleading
        .trim();
  }

  // Helper method to normalize gender values
  String _normalizeGender(String gender) {
    final normalizedGender = gender.toLowerCase().trim();
    if (normalizedGender == 'boys' || normalizedGender == 'men' || normalizedGender == 'male' || normalizedGender == 'm') {
      return 'boys';
    } else if (normalizedGender == 'girls' || normalizedGender == 'women' || normalizedGender == 'female' || normalizedGender == 'w') {
      return 'girls';
    }
    return normalizedGender;
  }

  // Debug method to log all available sports
  void logAvailableSports() {
    AppLogger.info('=== ALL AVAILABLE SPORTS DEBUG ===');
    AppLogger.info('Total athletes: ${athletes.length}');
    AppLogger.info('Total schedule events: ${schedule.length}');
    
    final athleteSports = athletes.map((a) => a.sport).toSet();
    final scheduleSports = schedule.map((s) => s.sport).toSet();
    
    AppLogger.info('Sports from athletes (${athleteSports.length}): ${athleteSports.toList()..sort()}');
    AppLogger.info('Sports from schedule (${scheduleSports.length}): ${scheduleSports.toList()..sort()}');
    
    final allSports = getAllAvailableSports();
    AppLogger.info('Combined normalized sports (${allSports.length}): $allSports');
  }
}