import 'package:get/get.dart';
import '../models/bulletin_post.dart';
import '../models/announcement.dart';
import '../models/general_event.dart';
import '../api.dart';

class BulletinController extends GetxController {
  // Observable lists for real data
  final RxList<BulletinPost> allPosts = <BulletinPost>[].obs;
  final RxList<Announcement> announcements = <Announcement>[].obs;
  final RxList<GeneralEvent> generalEvents = <GeneralEvent>[].obs;
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadData();
  }

  // Load all data from the API
  Future<void> loadData() async {
    isLoading.value = true;
    error.value = '';
    
    try {
      // Fetch data concurrently
      await Future.wait([
        loadAnnouncements(),
        loadGeneralEvents(),
      ]);
      
      // Combine into bulletin posts
      _updateAllPosts();
    } catch (e) {
      error.value = 'Failed to load data: $e';
      print('Error loading bulletin data: $e');
      // Use fallback data if API fails
      _loadFallbackData();
    } finally {
      isLoading.value = false;
    }
  }

  // Load announcements from API
  Future<void> loadAnnouncements() async {
    try {
      final fetchedAnnouncements = await ApiService.fetchAnnouncements();
      announcements.assignAll(fetchedAnnouncements);
    } catch (e) {
      print('Error loading announcements: $e');
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

  // Combine all data sources into bulletin posts
  void _updateAllPosts() {
    final List<BulletinPost> combinedPosts = [];
    
    // Convert announcements to bulletin posts
    for (final announcement in announcements) {
      combinedPosts.add(announcement.toBulletinPost());
    }
    
    // Convert general events to bulletin posts
    for (final event in generalEvents) {
      combinedPosts.add(event.toBulletinPost());
    }
    
    // Sort by date (newest first)
    combinedPosts.sort((a, b) => b.date.compareTo(a.date));
    
    allPosts.assignAll(combinedPosts);
  }

  // Fallback data when API is unavailable
  void _loadFallbackData() {
    allPosts.assignAll([
      BulletinPost(
        title: 'Homecoming Tickets on Sale!',
        subtitle: 'Get them before they sell out!',
        date: DateTime.now().add(const Duration(days: 2)),
        imagePath: 'assets/images/homecoming_bg.png',
        isPinned: true,
      ),
      BulletinPost(
        title: 'Spirit Week Next Week',
        subtitle: 'Show your school spirit!',
        date: DateTime.now().add(const Duration(days: 1)),
        imagePath: 'assets/images/homecoming_bg.png',
        isPinned: true,
      ),
      BulletinPost(
        title: 'Parent-Teacher Conferences',
        subtitle: 'Sign-ups are open',
        date: DateTime.now(),
        imagePath: 'assets/images/homecoming_bg.png',
      ),
      BulletinPost(
        title: 'Soccer Team Wins!',
        subtitle: 'A thrilling victory',
        date: DateTime.now().subtract(const Duration(days: 1)),
        imagePath: 'assets/images/homecoming_bg.png',
      ),
    ]);
  }

  // Refresh data
  Future<void> refreshData() async {
    await loadData();
  }

  // Utility: get only today and future events, sorted by date
  List<BulletinPost> get upcomingEvents {
    final now = DateTime.now();
    return allPosts.where((post) => !post.date.isBefore(DateTime(now.year, now.month, now.day))).toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  // Utility: get pinned posts
  List<BulletinPost> get pinnedPosts => allPosts.where((post) => post.isPinned).toList();
}
