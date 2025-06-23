// lib/presentation/placeholder_pages/bulletin_page.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:sticky_headers/sticky_headers.dart';

import '../../models/bulletin_post.dart';
import '../../models/article.dart';
import '../../widgets/article_detail_sheet.dart';
import '../../widgets/shared_header.dart';

class BulletinPage extends StatefulWidget {
  const BulletinPage({super.key});

  @override
  State<BulletinPage> createState() => _BulletinPageState();
}

class _BulletinPageState extends State<BulletinPage> {
  final List<BulletinPost> _allPosts = [
    BulletinPost(title: 'Homecoming Tickets on Sale!', subtitle: 'Get them before they sell out!', date: DateTime.now().add(const Duration(days: 2)), imagePath: 'assets/images/homecoming_bg.png', isPinned: true),
    BulletinPost(title: 'Spirit Week Next Week', subtitle: 'Show your school spirit!', date: DateTime.now().add(const Duration(days: 1)), imagePath: 'assets/images/homecoming_bg.png', isPinned: true),
    BulletinPost(title: 'Parent-Teacher Conferences', subtitle: 'Sign-ups are open', date: DateTime.now(), imagePath: 'assets/images/homecoming_bg.png'),
    BulletinPost(title: 'Soccer Team Wins!', subtitle: 'A thrilling victory', date: DateTime.now().subtract(const Duration(days: 1)), imagePath: 'assets/images/homecoming_bg.png'),
    BulletinPost(title: 'Fall Play Rehearsals', subtitle: 'After school in the auditorium', date: DateTime.now().subtract(const Duration(days: 2)), imagePath: 'assets/images/homecoming_bg.png'),
  ];

  Map<String, List<BulletinPost>> _groupedPosts = {};

  bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  @override
  void initState() {
    super.initState();
    _buildGroupedList();
  }
  
  void _buildGroupedList() {
    final today = DateTime.now();
    final nonPinnedPosts = _allPosts.where((post) => !post.isPinned).toList();
    nonPinnedPosts.sort((a, b) => a.date.compareTo(b.date));

    final Map<String, List<BulletinPost>> grouped = {};
    for (var post in nonPinnedPosts) {
      String dateHeader;
      if (isSameDay(post.date, today)) dateHeader = 'Today';
      else if (isSameDay(post.date, today.subtract(const Duration(days: 1)))) dateHeader = 'Yesterday';
      else if (isSameDay(post.date, today.add(const Duration(days: 1)))) dateHeader = 'Tomorrow';
      else dateHeader = DateFormat('EEEE, MMMM d').format(post.date);
      
      if (grouped[dateHeader] == null) grouped[dateHeader] = [];
      grouped[dateHeader]!.add(post);
    }
    setState(() => _groupedPosts = grouped);
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
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  @override
  Widget build(BuildContext context) {
    final pinnedPosts = _allPosts.where((post) => post.isPinned).toList();
    final dateKeys = _groupedPosts.keys.toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      body: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SharedHeader(title: 'Bulletin'),
              const SizedBox(height: 24),
              if (pinnedPosts.isNotEmpty) ...[
                _buildSectionHeader("Pinned"),
                _buildPinnedCarousel(pinnedPosts),
              ],
            ],
          ),
          DraggableScrollableSheet(
            // FIX: Slightly increased the initial and min size to raise the resting position.
            initialChildSize: 0.55,
            minChildSize: 0.55,
            maxChildSize: 0.9,
            builder: (context, scrollController) {
              return Container(
                decoration: const BoxDecoration(
                  color: Color(0xFFF2F2F7),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 20, spreadRadius: -5)],
                ),
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: dateKeys.length,
                  itemBuilder: (context, index) {
                    final date = dateKeys[index];
                    final postsForDate = _groupedPosts[date]!;
                    return StickyHeader(
                      header: _buildDateHeader(date),
                      content: Column(
                        children: postsForDate.map((post) => _BulletinEventCard(post: post)).toList(),
                      ),
                    );
                  },
                ),
              );
            },
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
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey.shade600),
      ),
    );
  }

  Widget _buildDateHeader(String date) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24.0, 16.0, 24.0, 16.0),
      decoration: const BoxDecoration(
        color: Color(0xFFF2F2F7),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
      ),
      child: Text(
        date,
        style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildPinnedCarousel(List<BulletinPost> posts) {
    return SizedBox(
      height: 220,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        itemCount: posts.length,
        itemBuilder: (context, index) {
          return _PinnedPostCard(post: posts[index]);
        },
      ),
    );
  }
}

class _BulletinEventCard extends StatelessWidget {
  const _BulletinEventCard({required this.post});
  final BulletinPost post;
  
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
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showArticleSheet(post),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
        child: Container(
          height: 280,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 15, offset: const Offset(0, 5))],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  flex: 3,
                  child: Image.asset(post.imagePath!, fit: BoxFit.cover),
                ),
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(post.title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Icon(Icons.calendar_today_outlined, size: 16, color: Colors.grey),
                            const SizedBox(width: 8),
                            Text(post.subtitle, style: TextStyle(fontSize: 14, color: Colors.grey.shade700)),
                            const Spacer(),
                            const Icon(Icons.more_horiz, size: 20, color: Colors.grey),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PinnedPostCard extends StatelessWidget {
  const _PinnedPostCard({required this.post});
  final BulletinPost post;

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
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showArticleSheet(post),
      child: Container(
        width: 250,
        margin: const EdgeInsets.only(right: 16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              child: Image.asset(post.imagePath!, height: 120, width: double.infinity, fit: BoxFit.cover),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(post.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16), maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Text(post.subtitle, style: TextStyle(fontSize: 14, color: Colors.grey.shade600), maxLines: 2, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
