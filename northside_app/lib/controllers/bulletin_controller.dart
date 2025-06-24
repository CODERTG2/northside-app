import 'package:get/get.dart';
import '../models/bulletin_post.dart';

class BulletinController extends GetxController {
  // The list of all bulletin posts (shared source of truth)
  final RxList<BulletinPost> allPosts = <BulletinPost>[ 
    BulletinPost(title: 'Homecoming Tickets on Sale!', subtitle: 'Get them before they sell out!', date: DateTime.now().add(const Duration(days: 2)), imagePath: 'assets/images/homecoming_bg.png', isPinned: true),
    BulletinPost(title: 'Spirit Week Next Week', subtitle: 'Show your school spirit!', date: DateTime.now().add(const Duration(days: 1)), imagePath: 'assets/images/homecoming_bg.png', isPinned: true),
    BulletinPost(title: 'Parent-Teacher Conferences', subtitle: 'Sign-ups are open', date: DateTime.now(), imagePath: 'assets/images/homecoming_bg.png'),
    BulletinPost(title: 'Soccer Team Wins!', subtitle: 'A thrilling victory', date: DateTime.now().subtract(const Duration(days: 1)), imagePath: 'assets/images/homecoming_bg.png'),
    BulletinPost(title: 'Fall Play Rehearsals', subtitle: 'After school in the auditorium', date: DateTime.now().subtract(const Duration(days: 2)), imagePath: 'assets/images/homecoming_bg.png'),
    // Decoy future days
    BulletinPost(title: 'Math Club Meeting', subtitle: 'Room 101 after school', date: DateTime.now().add(const Duration(days: 3)), imagePath: 'assets/images/homecoming_bg.png'),
    BulletinPost(title: 'Chess Tournament', subtitle: 'Sign up now!', date: DateTime.now().add(const Duration(days: 4)), imagePath: 'assets/images/homecoming_bg.png'),
    BulletinPost(title: 'Science Fair Prep', subtitle: 'Lab open for projects', date: DateTime.now().add(const Duration(days: 5)), imagePath: 'assets/images/homecoming_bg.png'),
    BulletinPost(title: 'Band Practice', subtitle: 'Auditorium, 3:30pm', date: DateTime.now().add(const Duration(days: 6)), imagePath: 'assets/images/homecoming_bg.png'),
    BulletinPost(title: 'College Info Night', subtitle: 'Counseling office, 6pm', date: DateTime.now().add(const Duration(days: 7)), imagePath: 'assets/images/homecoming_bg.png'),
  ].obs;

  // Utility: get only today and future events, sorted by date
  List<BulletinPost> get upcomingEvents {
    final now = DateTime.now();
    return allPosts.where((post) => !post.date.isBefore(DateTime(now.year, now.month, now.day))).toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  // Utility: get pinned posts
  List<BulletinPost> get pinnedPosts => allPosts.where((post) => post.isPinned).toList();
}
