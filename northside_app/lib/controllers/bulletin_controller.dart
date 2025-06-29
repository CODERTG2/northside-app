// lib/controllers/bulletin_controller.dart

import 'package:get/get.dart';
import '../models/bulletin_post.dart';
import '../models/announcement.dart';
import '../models/general_event.dart';
import '../models/athletics_schedule.dart';
import '../api.dart';
import '../core/utils/logger.dart';

class BulletinController extends GetxController {
  // Observable lists for reactive UI
  final RxList<BulletinPost> _allPosts = <BulletinPost>[].obs;
  final RxBool _isLoading = false.obs;
  
  // Store original announcements for home carousel (not included in bulletin posts)
  List<Announcement> _announcements = [];
  List<AthleticsSchedule> _athleticsEvents = [];

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

      // Store original data for home carousel
      _announcements = announcements;
      _athleticsEvents = athleticsEvents;

      // Combine into bulletin posts (excluding athletics)
      final bulletinPosts = _createBulletinPosts(announcements, generalEvents, athleticsEvents);
      
      // Update the observable list
      _allPosts.assignAll(bulletinPosts);
    } catch (e) {
      AppLogger.error('Error loading bulletin data', e);
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
      AppLogger.error('Error loading announcements', e);
      return [];
    }
  }

  // Load general events
  Future<List<GeneralEvent>> _loadGeneralEvents() async {
    try {
      final fetchedEvents = await ApiService.getGeneralEvents();
      return fetchedEvents;
    } catch (e) {
      AppLogger.error('Error loading general events', e);
      return [];
    }
  }

  // Load athletics events
  Future<List<AthleticsSchedule>> _loadAthleticsEvents() async {
    try {
      final fetchedEvents = await ApiService.getAthleticsSchedule();
      return fetchedEvents;
    } catch (e) {
      AppLogger.error('Error loading athletics events', e);
      return [];
    }
  }

  // Create bulletin posts from announcements and events (excluding athletics)
  List<BulletinPost> _createBulletinPosts(List<Announcement> announcements, List<GeneralEvent> generalEvents, List<AthleticsSchedule> athleticsEvents) {
    final List<BulletinPost> combinedPosts = [];
    
    // Convert announcements to bulletin posts (using start_date for bulletin display)
    for (final announcement in announcements) {
      final bulletinPost = announcement.toBulletinPost(useEndDate: false);
      combinedPosts.add(bulletinPost);
    }
    
    // Convert general events to bulletin posts
    for (final event in generalEvents) {
      final bulletinPost = event.toBulletinPost();
      combinedPosts.add(bulletinPost);
    }
    
    // Note: Athletics events are excluded from bulletin posts
    // They appear only on the athletics page
    
    // Sort by date (newest first)
    combinedPosts.sort((a, b) => b.date.compareTo(a.date));
    
    return combinedPosts;
  }

  // Refresh data
  Future<void> refresh() async {
    await loadData();
  }

  // Get upcoming events (future events only) for home screen carousel (includes athletics and announcements)
  List<BulletinPost> get upcomingEvents {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    
    // Create combined posts including athletics for home carousel
    final List<BulletinPost> homeCarouselPosts = [];
    
    // Add general events (filter out announcements from allPosts)
    final generalEventPosts = allPosts.where((post) => 
        post.imagePath != 'assets/images/flexes_icon.png').toList();
    
    for (final post in generalEventPosts) {
      if (!post.date.isBefore(todayStart)) {
        homeCarouselPosts.add(post);
      }
    }
    
    // Add announcements using end_date for home carousel relevance
    for (final announcement in _announcements) {
      final bulletinPost = announcement.toBulletinPost(useEndDate: true);
      if (!bulletinPost.date.isBefore(todayStart)) {
        homeCarouselPosts.add(bulletinPost);
      }
    }
    
    // Add athletics events for home carousel
    for (final event in _athleticsEvents) {
      final bulletinPost = event.toBulletinPost();
      if (!bulletinPost.date.isBefore(todayStart)) {
        homeCarouselPosts.add(bulletinPost);
      }
    }
    
    // Sort by date (earliest first for carousel)
    homeCarouselPosts.sort((a, b) => a.date.compareTo(b.date));
    
    return homeCarouselPosts.take(10).toList(); // Limit to 10 for performance
  }

  @override
  void onReady() {
    super.onReady();
    loadData();
  }

  // Get pinned posts (5 most recent announcements and events for today or near future)
  List<BulletinPost> get pinnedPosts {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    
    final List<BulletinPost> candidatePosts = [];
    
    // Add general events (filter out announcements from allPosts - these use start_date)
    final generalEventPosts = allPosts.where((post) => 
        post.imagePath != 'assets/images/flexes_icon.png').toList();
    
    for (final post in generalEventPosts) {
      if (!post.date.isBefore(todayStart)) {
        candidatePosts.add(post);
      }
    }
    
    // Add announcements using end_date for pinned post relevance
    for (final announcement in _announcements) {
      final bulletinPost = announcement.toBulletinPost(useEndDate: true);
      if (!bulletinPost.date.isBefore(todayStart)) {
        candidatePosts.add(bulletinPost);
      }
    }
    
    // Sort by date (earliest first)
    candidatePosts.sort((a, b) => a.date.compareTo(b.date));
    
    // Take top 5 and mark as pinned
    return candidatePosts.take(5).map((post) => BulletinPost(
      title: post.title,
      subtitle: post.subtitle,
      date: post.date,
      content: post.content,
      imagePath: post.imagePath,
      isPinned: true,
    )).toList();
  }

  // Get future posts (beyond the next 7 days)
  List<BulletinPost> get futurePosts {
    final now = DateTime.now();
    final nearFuture = now.add(const Duration(days: 7));
    
    final future = allPosts.where((post) => !post.date.isBefore(nearFuture)).toList();
    future.sort((a, b) => a.date.compareTo(b.date)); // Earliest first
    
    return future;
  }

  // Get past posts (before today)
  List<BulletinPost> get pastPosts {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    
    final past = allPosts.where((post) => post.date.isBefore(todayStart)).toList();
    past.sort((a, b) => b.date.compareTo(a.date)); // Most recent first
    
    return past;
  }
}
