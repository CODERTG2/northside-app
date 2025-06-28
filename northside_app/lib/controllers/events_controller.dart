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
      final fetchedEvents = await ApiService.fetchGeneralEvents();
      generalEvents.assignAll(fetchedEvents);
    } catch (e) {
      print('Error loading general events: $e');
    }
  }

  // Load athletics events from API
  Future<void> loadAthleticsEvents() async {
    try {
      final fetchedEvents = await ApiService.fetchAthleticsSchedule();
      athleticsEvents.assignAll(fetchedEvents);
    } catch (e) {
      print('Error loading athletics events: $e');
    }
  }

  // Get events for a specific date
  List<Article> getEventsForDay(DateTime date) {
    final dateString = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    final events = <Article>[];

    // Add general events for this date
    final dayGeneralEvents = generalEvents.where((event) => event.date == dateString);
    events.addAll(dayGeneralEvents.map((event) => event.toArticle()));

    // Add athletics events for this date
    final dayAthleticsEvents = athleticsEvents.where((event) => event.date == dateString);
    events.addAll(dayAthleticsEvents.map((event) => event.toArticle()));

    return events;
  }

  // Get all events as a map for calendar
  Map<DateTime, List<Article>> getAllEventsMap() {
    final eventsMap = <DateTime, List<Article>>{};

    // Add general events
    for (final event in generalEvents) {
      try {
        final date = DateTime.parse(event.date);
        final dayKey = DateTime(date.year, date.month, date.day);
        if (eventsMap[dayKey] == null) {
          eventsMap[dayKey] = [];
        }
        eventsMap[dayKey]!.add(event.toArticle());
      } catch (e) {
        print('Error parsing date for general event: ${event.date}');
      }
    }

    // Add athletics events
    for (final event in athleticsEvents) {
      try {
        final date = DateTime.parse(event.date);
        final dayKey = DateTime(date.year, date.month, date.day);
        if (eventsMap[dayKey] == null) {
          eventsMap[dayKey] = [];
        }
        eventsMap[dayKey]!.add(event.toArticle());
      } catch (e) {
        print('Error parsing date for athletics event: ${event.date}');
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
        final eventDate = DateTime.parse(event.date);
        return eventDate.isAfter(now) && eventDate.isBefore(weekFromNow);
      } catch (e) {
        return false;
      }
    });
    upcomingEvents.addAll(upcomingGeneral.map((event) => event.toArticle()));

    // Add upcoming athletics events
    final upcomingAthletics = athleticsEvents.where((event) {
      try {
        final eventDate = DateTime.parse(event.date);
        return eventDate.isAfter(now) && eventDate.isBefore(weekFromNow);
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

  // Refresh data
  Future<void> refreshData() async {
    await loadData();
  }
}
