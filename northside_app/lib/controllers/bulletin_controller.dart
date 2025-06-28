// lib/controllers/bulletin_controller.dart

import 'package:get/get.dart';
import '../models/bulletin_post.dart';
import '../models/announcement.dart';
import '../models/general_event.dart';
import '../models/athletics_schedule.dart';
import '../api.dart';

class BulletinController extends GetxController {
  final ApiService _apiService = ApiService();

  // Observable lists for reactive UI
  final RxList<BulletinPost> _allPosts = <BulletinPost>[].obs;
  final RxBool _isLoading = false.obs;

  // Getters
  List<BulletinPost> get allPosts => _allPosts;
  RxList<BulletinPost> get allPostsRx => _allPosts;
  bool get isLoading => _isLoading.value;

  @override
  void onInit() {
    super.onInit();
    loadData();
  }

  // Load and combine data from all sources
  Future<void> loadData() async {
    try {
      _isLoading.value = true;
      
      // Load data from all sources
      final announcements = await _loadAnnouncements();
      final generalEvents = await _loadGeneralEvents();
      final athleticsEvents = await _loadAthleticsEvents();

      // Combine into bulletin posts
      final bulletinPosts = _createBulletinPosts(announcements, generalEvents, athleticsEvents);
      
      // Update the observable list
      _allPosts.assignAll(bulletinPosts);
    } catch (e) {
      print('Error loading bulletin data: $e');
    } finally {
      _isLoading.value = false;
    }
  }

  // Load announcements
  Future<List<Announcement>> _loadAnnouncements() async {
    try {
      final fetchedAnnouncements = await ApiService.getAnnouncements();
      return fetchedAnnouncements;
    } catch (e) {
      print('Error loading announcements: $e');
      return [];
    }
  }

  // Load general events
  Future<List<GeneralEvent>> _loadGeneralEvents() async {
    try {
      final fetchedEvents = await ApiService.getGeneralEvents();
      return fetchedEvents;
    } catch (e) {
      print('Error loading general events: $e');
      return [];
    }
  }

  // Load athletics events
  Future<List<AthleticsSchedule>> _loadAthleticsEvents() async {
    try {
      final fetchedEvents = await ApiService.getAthleticsSchedule();
      return fetchedEvents;
    } catch (e) {
      print('Error loading athletics events: $e');
      return [];
    }
  }

  // Create bulletin posts from announcements, events, and athletics
  List<BulletinPost> _createBulletinPosts(List<Announcement> announcements, List<GeneralEvent> generalEvents, List<AthleticsSchedule> athleticsEvents) {
    final List<BulletinPost> combinedPosts = [];
    
    // Convert announcements to bulletin posts
    for (final announcement in announcements) {
      final bulletinPost = announcement.toBulletinPost();
      combinedPosts.add(bulletinPost);
    }
    
    // Convert general events to bulletin posts
    for (final event in generalEvents) {
      final bulletinPost = event.toBulletinPost();
      combinedPosts.add(bulletinPost);
    }
    
    // Convert athletics events to bulletin posts
    for (final event in athleticsEvents) {
      final bulletinPost = event.toBulletinPost();
      combinedPosts.add(bulletinPost);
    }
    
    // Sort by date (newest first)
    combinedPosts.sort((a, b) => b.date.compareTo(a.date));
    
    return combinedPosts;
  }

  // Refresh data
  Future<void> refresh() async {
    await loadData();
  }

  // Get upcoming events (future events only) for home screen carousel
  List<BulletinPost> get upcomingEvents {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    
    // Filter events that are today or in the future
    final upcoming = allPosts.where((post) {
      return !post.date.isBefore(todayStart);
    }).toList();
    
    // Sort by date (earliest first for carousel)
    upcoming.sort((a, b) => a.date.compareTo(b.date));
    
    return upcoming.take(10).toList(); // Limit to 10 for performance
  }

  @override
  void onReady() {
    super.onReady();
    loadData();
  }

  // Get pinned posts
  List<BulletinPost> get pinnedPosts => allPosts.where((post) => post.isPinned).toList();

  // Get recent posts (last 3 days)
  List<BulletinPost> get recentPosts {
    final now = DateTime.now();
    final threeDaysAgo = now.subtract(const Duration(days: 3));
    
    final recent = allPosts.where((post) => !post.date.isBefore(threeDaysAgo)).toList();
    
    return recent;
  }
}
