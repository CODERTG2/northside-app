// lib/controllers/events_controller.dart

import 'package:get/get.dart';
import '../models/general_event.dart';
import '../models/athletics_schedule.dart';
import '../models/article.dart';
import '../api.dart';

class EventsController extends GetxController {
  // Observable lists for real data
  final RxList<GeneralEvent> generalEvents = <GeneralEvent>[].obs;
  final RxList<AthleticsSchedule> athleticsEvents = <AthleticsSchedule>[].obs;
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;

  @override
  void onInit() {
    super.onInit();
    print('EventsController initialized');
    loadData();
  }

  @override
  void onReady() {
    super.onReady();
    print('EventsController ready');
    // Refresh data when controller is ready
    loadData();
  }

  // Load all events data
  Future<void> loadData() async {
    isLoading.value = true;
    error.value = '';
    
    try {
      await Future.wait([
        loadGeneralEvents(),
        loadAthleticsEvents(),
      ]);
    } catch (e) {
      error.value = 'Failed to load events data: $e';
      print('Error loading events data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Load general events from API
  Future<void> loadGeneralEvents() async {
    try {
      final fetchedEvents = await ApiService.getGeneralEvents();
      generalEvents.assignAll(fetchedEvents);
      print('Loaded ${generalEvents.length} general events');
      // Debug: print first few items
      if (generalEvents.isNotEmpty) {
        for (int i = 0; i < generalEvents.length && i < 3; i++) {
          print('General Event $i: ${generalEvents[i].date} - ${generalEvents[i].name}');
        }
      }
    } catch (e) {
      print('Error loading general events: $e');
    }
  }

  // Load athletics events from API
  Future<void> loadAthleticsEvents() async {
    try {
      final fetchedEvents = await ApiService.getAthleticsSchedule();
      athleticsEvents.assignAll(fetchedEvents);
      print('Loaded ${athleticsEvents.length} athletics events');
      // Debug: print first few items
      if (athleticsEvents.isNotEmpty) {
        for (int i = 0; i < athleticsEvents.length && i < 3; i++) {
          print('Athletics Event $i: ${athleticsEvents[i].date} - ${athleticsEvents[i].sport} - ${athleticsEvents[i].opponent}');
        }
      }
    } catch (e) {
      print('Error loading athletics events: $e');
    }
  }

  // Get events for a specific date
  List<Article> getEventsForDay(DateTime date) {
    final events = <Article>[];

    // Add general events for this date
    final dayGeneralEvents = generalEvents.where((event) {
      try {
        final eventDate = _parseEventDate(event.date);
        return eventDate != null && _isSameDay(eventDate, date);
      } catch (e) {
        return false;
      }
    });
    events.addAll(dayGeneralEvents.map((event) => event.toArticle()));

    // Add athletics events for this date
    final dayAthleticsEvents = athleticsEvents.where((event) {
      try {
        final eventDate = _parseEventDate(event.date);
        return eventDate != null && _isSameDay(eventDate, date);
      } catch (e) {
        return false;
      }
    });
    events.addAll(dayAthleticsEvents.map((event) => event.toArticle()));

    return events;
  }

  // Helper method to parse various date formats
  DateTime? _parseEventDate(String dateString) {
    if (dateString.isEmpty) return null;
    
    try {
      // Try parsing M/D/YYYY format first (most common in our data)
      if (dateString.contains('/')) {
        final parts = dateString.split('/');
        if (parts.length == 3) {
          int month = int.tryParse(parts[0]) ?? 1;
          final day = int.tryParse(parts[1]) ?? 1;
          final year = int.tryParse(parts[2]) ?? DateTime.now().year;
          
          // Handle 0-based month indexing from backend scraper (0 = January, 11 = December)
          if (month >= 0 && month <= 11) {
            month = month + 1; // Convert 0-11 to 1-12
          }
          
          // Validate month range
          if (month < 1 || month > 12) month = 1;
          
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
      print('Error parsing date: $dateString - $e');
      return null;
    }
  }

  // Helper method to check if two dates are on the same day
  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year && 
           date1.month == date2.month && 
           date1.day == date2.day;
  }

  // Get all events as a map for calendar
  Map<DateTime, List<Article>> getAllEventsMap() {
    final eventsMap = <DateTime, List<Article>>{};

    // Add general events
    for (final event in generalEvents) {
      try {
        final date = _parseEventDate(event.date);
        if (date != null) {
          final dayKey = DateTime(date.year, date.month, date.day);
          if (eventsMap[dayKey] == null) {
            eventsMap[dayKey] = [];
          }
          eventsMap[dayKey]!.add(event.toArticle());
        }
      } catch (e) {
        print('Error parsing date for general event: ${event.date} - $e');
      }
    }

    // Add athletics events
    for (final event in athleticsEvents) {
      try {
        final date = _parseEventDate(event.date);
        if (date != null) {
          final dayKey = DateTime(date.year, date.month, date.day);
          if (eventsMap[dayKey] == null) {
            eventsMap[dayKey] = [];
          }
          eventsMap[dayKey]!.add(event.toArticle());
        }
      } catch (e) {
        print('Error parsing date for athletics event: ${event.date} - $e');
      }
    }

    return eventsMap;
  }

  // Get upcoming events (next 7 days)
  List<Article> getUpcomingEvents() {
    final now = DateTime.now();
    final weekFromNow = now.add(const Duration(days: 7));
    final upcomingEvents = <Article>[];

    // Add upcoming general events
    final upcomingGeneral = generalEvents.where((event) {
      try {
        final eventDate = _parseEventDate(event.date);
        return eventDate != null && eventDate.isAfter(now) && eventDate.isBefore(weekFromNow);
      } catch (e) {
        return false;
      }
    });
    upcomingEvents.addAll(upcomingGeneral.map((event) => event.toArticle()));

    // Add upcoming athletics events
    final upcomingAthletics = athleticsEvents.where((event) {
      try {
        final eventDate = _parseEventDate(event.date);
        return eventDate != null && eventDate.isAfter(now) && eventDate.isBefore(weekFromNow);
      } catch (e) {
        return false;
      }
    });
    upcomingEvents.addAll(upcomingAthletics.map((event) => event.toArticle()));

    // Sort by date
    upcomingEvents.sort((a, b) {
      // Since Article doesn't have date, we'll use the subtitle which should contain time info
      return a.subtitle.compareTo(b.subtitle);
    });

    return upcomingEvents;
  }

  // Get all events (for debugging and testing)
  List<Article> getAllEvents() {
    final allEvents = <Article>[];
    
    // Add all general events
    allEvents.addAll(generalEvents.map((event) => event.toArticle()));
    
    // Add all athletics events
    allEvents.addAll(athleticsEvents.map((event) => event.toArticle()));
    
    print('Total events: ${allEvents.length} (${generalEvents.length} general + ${athleticsEvents.length} athletics)');
    
    return allEvents;
  }

  // Refresh data
  Future<void> refreshData() async {
    await loadData();
  }
}
