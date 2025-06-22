// lib/presentation/placeholder_pages/bulletin_page.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart'; // FIX: Added the missing import

import '../../models/bulletin_post.dart';
import '../../models/article.dart';
import '../../widgets/article_detail_sheet.dart';
import '../../widgets/shared_header.dart';

// --- CENTRAL DATA SOURCE ---
final List<Article> allAnnouncements = [
  // Pinned Items
  Article(
    title: 'Finals Week Schedule',
    subtitle: 'Important Dates & Times',
    imagePath: 'assets/images/homecoming_bg.png',
    date: DateTime.now().add(const Duration(days: 10)),
    content: 'Detailed schedule for final exams.',
    isPinned: true,
  ),
  Article(
    title: 'Summer Break Info',
    subtitle: 'Last Day of School: June 28',
    imagePath: 'assets/images/homecoming_bg.png',
    date: DateTime.now().add(const Duration(days: 20)),
    content: 'Information about the upcoming summer break.',
    isPinned: true,
  ),
  // Past Items
  Article(
    title: 'Last Week\'s Soccer Game',
    subtitle: 'A thrilling victory!',
    date: DateTime.now().subtract(const Duration(days: 7)),
    content: 'A recap of the amazing game last week.',
  ),
  Article(
    title: 'Yesterday\'s Bake Sale',
    subtitle: 'Raised over \$500!',
    date: DateTime.now().subtract(const Duration(days: 1)),
    content: 'Thank you for your support!',
  ),
  // Today's Items
  Article(
    title: 'Parent-Teacher Conferences',
    subtitle: 'Today in the main hall',
    date: DateTime.now(),
    content: 'Conferences are happening all day today.',
  ),
  Article(
    title: 'Library Closing Early',
    subtitle: 'Closes at 3 PM today',
    date: DateTime.now(),
    content: 'The library will be closing early for maintenance.',
  ),
  // Future Items
  Article(
    title: 'Homecoming 2024',
    subtitle: 'This Friday',
    imagePath: 'assets/images/homecoming_bg.png',
    date: DateTime.now().add(const Duration(days: 3)),
    content: 'Join us for a night of fun and festivities!',
  ),
  Article(
    title: 'Spirit Week',
    subtitle: 'Starts next Monday!',
    date: DateTime.now().add(const Duration(days: 5)),
    content: 'Get ready for a week of school spirit!',
  ),
];
// --- END OF DATA SOURCE ---

class BulletinPage extends StatefulWidget {
  const BulletinPage({super.key});

  @override
  State<BulletinPage> createState() => _BulletinPageState();
}

class _BulletinPageState extends State<BulletinPage> {
  // --- Placeholder Data ---
  final List<BulletinPost> _allPosts = [
    BulletinPost(title: 'Homecoming Tickets on Sale!', subtitle: 'Get them before they sell out!', date: DateTime.now().add(const Duration(days: 2)), imagePath: 'assets/images/homecoming_bg.png', isPinned: true),
    BulletinPost(title: 'Spirit Week Next Week', subtitle: 'Show your school spirit!', date: DateTime.now().add(const Duration(days: 1)), imagePath: 'assets/images/homecoming_bg.png', isPinned: true),
    BulletinPost(title: 'Parent-Teacher Conferences', subtitle: 'Sign-ups are open', date: DateTime.now(), imagePath: 'assets/images/homecoming_bg.png'),
    BulletinPost(title: 'Soccer Team Wins!', subtitle: 'A thrilling victory', date: DateTime.now().subtract(const Duration(days: 1)), imagePath: 'assets/images/homecoming_bg.png'),
    BulletinPost(title: 'School Play Auditions', subtitle: 'In the auditorium', date: DateTime.now().add(const Duration(days: 5)), imagePath: 'assets/images/homecoming_bg.png'),
  ];
  // --- End Placeholder Data ---
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _todayKey = GlobalKey();

  List<dynamic> _groupedItems = [];

  @override
  void initState() {
    super.initState();
    _buildGroupedList();
  }
  
  void _buildGroupedList() {
    final today = DateTime.now();
    final nonPinnedPosts = _allPosts.where((post) => !post.isPinned).toList();
    nonPinnedPosts.sort((a, b) => b.date.compareTo(a.date));

    final Map<String, List<BulletinPost>> grouped = {};
    for (var post in nonPinnedPosts) {
      String dateHeader;
      if (isSameDay(post.date, today)) {
        dateHeader = 'Today';
      } else if (isSameDay(post.date, today.subtract(const Duration(days: 1)))) {
        dateHeader = 'Yesterday';
      } else {
        dateHeader = DateFormat('MMMM d, yyyy').format(post.date);
      }
      if (grouped[dateHeader] == null) {
        grouped[dateHeader] = [];
      }
      grouped[dateHeader]!.add(post);
    }
    
    final List<dynamic> flattenedList = [];
    grouped.forEach((date, posts) {
      flattenedList.add(date);
      flattenedList.addAll(posts);
    });
    setState(() {
      _groupedItems = flattenedList;
    });
  }

  void _showArticleSheet(BulletinPost post) {
    Get.bottomSheet(
      ArticleDetailSheet(
        article: Article(
          title: post.title,
          subtitle: post.subtitle,
          imagePath: post.imagePath,
          content: post.content,
        ),
      ),
      
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final context = _todayKey.currentContext;
      if (context != null) {
        Scrollable.ensureVisible(context,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
            alignment: 0.05
        );
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _showArticleSheet(Article article) {
    Get.bottomSheet(
      ArticleDetailSheet(article: article),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  @override
  Widget build(BuildContext context) {
    final pinnedPosts = _allPosts.where((post) => post.isPinned).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      body: CustomScrollView(
        slivers: [
          const SliverToBoxAdapter(child: SharedHeader(title: 'Bulletin')),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
          if (pinnedPosts.isNotEmpty) ...[
            SliverToBoxAdapter(child: _buildSectionHeader("Pinned")),
            SliverToBoxAdapter(child: _buildPinnedCarousel(pinnedPosts)),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final item = _groupedItems[index];
                if (item is String) {
                  return _buildDateHeader(item);
                } else if (item is BulletinPost) {
                  return _buildEventCard(item);
                }
                return const SizedBox.shrink();
              },
              childCount: _groupedItems.length,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24.0, 0, 24.0, 16.0),
      child: Text(
        title,
        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.grey.shade600),
      ),
    );
  }

  Widget _buildDateHeader(String date) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24.0, 24.0, 24.0, 16.0),
      child: Text(
        date,
        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildPinnedCarousel(List<BulletinPost> posts) {
    return SizedBox(
      height: 150,
      child: PageView.builder(
        controller: PageController(viewportFraction: 0.85),
        clipBehavior: Clip.none,
        itemCount: posts.length,
        itemBuilder: (context, index) {
          return _buildEventCard(posts[index], isPinned: true);
        },
      ),
    );
  }

  Widget _buildEventCard(BulletinPost post, {bool isPinned = false}) {
    return GestureDetector(
      onTap: () => _showArticleSheet(post),
      child: Container(
        margin: isPinned ? const EdgeInsets.only(right: 16) : const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: isPinned ? BorderRadius.circular(20) : const BorderRadius.vertical(top: Radius.circular(20)),
                child: Image.asset(post.imagePath!, fit: BoxFit.cover),
              ),
            ),
            if (!isPinned)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(post.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(post.subtitle, style: TextStyle(color: Colors.grey.shade600)),
                  ],
                ),
              )
          ],
        ),
      ),
    );
  }
}
    final pinned = allAnnouncements.where((a) => a.isPinned).toList();
    final nonPinned = allAnnouncements.where((a) => !a.isPinned).toList();
    nonPinned.sort((a, b) => a.date.compareTo(b.date));

    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverAppBar(
            backgroundColor: const Color(0xFFF2F2F7),
            expandedHeight: 200.0,
            pinned: false,
            flexibleSpace: FlexibleSpaceBar(
              background: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SharedHeader(title: 'Bulletin'),
                  const SizedBox(height: 16),
                  _buildSectionHeader("Pinned"),
                  const SizedBox(height: 16),
                  _buildPinnedCarousel(pinned),
                ],
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final article = nonPinned[index];
                final isFirst = index == 0;
                final previousArticleDate = isFirst ? null : nonPinned[index - 1].date;
                final showDateHeader = isFirst || !isSameDay(article.date, previousArticleDate);
                final isToday = isSameDay(article.date, DateTime.now());
                final isFirstToday = isToday && (isFirst || !isSameDay(previousArticleDate, DateTime.now()));
                
                return Column(
                  children: [
                    if (showDateHeader)
                      _buildDateHeader(article.date, key: isFirstToday ? _todayKey : null),
                    GestureDetector(
                      onTap: () => _showArticleSheet(article),
                      child: _buildAnnouncementCard(article),
                    ),
                  ],
                );
              },
              childCount: nonPinned.length,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Text(
        title,
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey.shade700),
      ),
    );
  }

  Widget _buildPinnedCarousel(List<Article> articles) {
    return SizedBox(
      height: 100,
      child: PageView.builder(
        controller: PageController(viewportFraction: 0.88),
        clipBehavior: Clip.none,
        itemCount: articles.length,
        itemBuilder: (context, index) {
          final article = articles[index];
          return GestureDetector(
            onTap: () => _showArticleSheet(article),
            child: Container(
              margin: const EdgeInsets.only(right: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 10, offset: const Offset(0, 4))],
              ),
              child: _buildAnnouncementCard(article, isPinned: true),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDateHeader(DateTime date, {Key? key}) {
    String formattedDate;
    final now = DateTime.now();
    if (isSameDay(date, now)) {
      formattedDate = 'Today';
    } else if (isSameDay(date, now.add(const Duration(days: 1)))) {
      formattedDate = 'Tomorrow';
    } else if (isSameDay(date, now.subtract(const Duration(days: 1)))) {
      formattedDate = 'Yesterday';
    } else {
      formattedDate = DateFormat('EEEE, MMMM d').format(date);
    }

    return Padding(
      key: key,
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
      child: Text(
        formattedDate,
        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildAnnouncementCard(Article article, {bool isPinned = false}) {
    return Container(
      margin: isPinned ? EdgeInsets.zero : const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
      padding: const EdgeInsets.all(16),
      decoration: isPinned ? null : BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          if (article.imagePath != null) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(article.imagePath!, width: 60, height: 60, fit: BoxFit.cover),
            ),
            const SizedBox(width: 16),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(article.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Text(article.subtitle, style: TextStyle(fontSize: 14, color: Colors.grey.shade600), maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        ],
      ),
    );
  }
}

// FIX: Added this helper function to the file to resolve the error.
bool isSameDay(DateTime? a, DateTime? b) {
  if (a == null || b == null) {
    return false;
  }
  return a.year == b.year && a.month == b.month && a.day == b.day;
}
