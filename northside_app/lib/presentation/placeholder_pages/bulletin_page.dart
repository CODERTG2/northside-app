// lib/presentation/placeholder_pages/bulletin_page.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../../models/bulletin_post.dart';
import '../../models/article.dart';
import '../../widgets/article_detail_sheet.dart';

class BulletinPage extends StatefulWidget {
  const BulletinPage({super.key});

  @override
  State<BulletinPage> createState() => _BulletinPageState();
}

class _BulletinPageState extends State<BulletinPage> {
  final ItemScrollController _itemScrollController = ItemScrollController();
  final ItemPositionsListener _itemPositionsListener = ItemPositionsListener.create();

  String _currentHeaderText = 'Bulletin';
  bool _showGoToTodayButton = false;
  int _todayIndex = -1;
  List<dynamic> _groupedItems = [];

  final List<BulletinPost> _allPosts = [
    BulletinPost(title: 'Homecoming Tickets on Sale!', subtitle: 'Get them before they sell out!', date: DateTime.now().add(const Duration(days: 2)), imagePath: 'assets/images/homecoming_bg.png', isPinned: true),
    BulletinPost(title: 'Spirit Week Next Week', subtitle: 'Show your school spirit!', date: DateTime.now().add(const Duration(days: 1)), imagePath: 'assets/images/homecoming_bg.png', isPinned: true),
    BulletinPost(title: 'Parent-Teacher Conferences', subtitle: 'Sign-ups are open', date: DateTime.now(), imagePath: 'assets/images/homecoming_bg.png'),
    BulletinPost(title: 'Soccer Team Wins!', subtitle: 'A thrilling victory', date: DateTime.now().subtract(const Duration(days: 1)), imagePath: 'assets/images/homecoming_bg.png'),
    BulletinPost(title: 'Fall Play Rehearsals', subtitle: 'After school in the auditorium', date: DateTime.now().subtract(const Duration(days: 1)), imagePath: 'assets/images/homecoming_bg.png'),
    BulletinPost(title: 'School Play Auditions', subtitle: 'In the auditorium', date: DateTime.now().add(const Duration(days: 5)), imagePath: 'assets/images/homecoming_bg.png'),
    BulletinPost(title: 'Club Fair Sign-ups', subtitle: 'In the main hallway during lunch', date: DateTime.now().add(const Duration(days: 6)), imagePath: 'assets/images/homecoming_bg.png'),
  ];

  @override
  void initState() {
    super.initState();
    _buildGroupedList();
    _itemPositionsListener.itemPositions.addListener(_updateHeaderAndButton);
  }
  
  @override
  void dispose() {
    _itemPositionsListener.itemPositions.removeListener(_updateHeaderAndButton);
    super.dispose();
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
      if (grouped[dateHeader] == null) grouped[dateHeader] = [];
      grouped[dateHeader]!.add(post);
    }
    
    final List<dynamic> flattenedList = [];
    grouped.forEach((date, posts) {
      flattenedList.add(date);
      flattenedList.addAll(posts);
    });

    setState(() {
      _groupedItems = flattenedList;
      _todayIndex = _groupedItems.indexWhere((item) => item is String && item == 'Today');
    });
  }

  void _updateHeaderAndButton() {
    if (_groupedItems.isEmpty || _itemPositionsListener.itemPositions.value.isEmpty) return;

    final firstVisibleItem = _itemPositionsListener.itemPositions.value
        .where((item) => item.itemLeadingEdge < 1)
        .last;
    
    final item = _groupedItems[firstVisibleItem.index];
    String newHeaderText = "Bulletin";

    if (item is String) {
      newHeaderText = item;
    } else if (item is BulletinPost) {
      for (var i = firstVisibleItem.index; i >= 0; i--) {
        if (_groupedItems[i] is String) {
          newHeaderText = _groupedItems[i] as String;
          break;
        }
      }
    }
    
    if (newHeaderText != _currentHeaderText) {
      setState(() {
        _currentHeaderText = newHeaderText;
      });
    }

    final showButton = _todayIndex != -1 && firstVisibleItem.index >= _todayIndex;
    if (showButton != _showGoToTodayButton) {
      setState(() {
        _showGoToTodayButton = showButton;
      });
    }
  }
  
  void _scrollToToday() {
    if (_todayIndex != -1) {
      _itemScrollController.scrollTo(
        index: _todayIndex,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
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
      body: Stack(
        children: [
          ScrollablePositionedList.builder(
            itemScrollController: _itemScrollController,
            itemPositionsListener: _itemPositionsListener,
            itemCount: _groupedItems.length,
            padding: EdgeInsets.only(top: pinnedPosts.isNotEmpty ? 300 : 120, bottom: 40),
            itemBuilder: (context, index) {
              final item = _groupedItems[index];
              if (item is String) {
                return _buildDateHeader(item);
              } else if (item is BulletinPost) {
                return _buildEventCard(item);
              }
              return const SizedBox.shrink();
            },
          ),
          _buildDynamicHeader(pinnedPosts),
          if (_showGoToTodayButton)
            Positioned(
              bottom: 100,
              left: 0,
              right: 0,
              child: Center(child: _buildGoToTodayButton()),
            ),
        ],
      ),
    );
  }
  
  Widget _buildDynamicHeader(List<BulletinPost> pinnedPosts) {
    return Container(
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
      color: const Color(0xFFF2F2F7).withOpacity(0.95),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(_currentHeaderText, style: const TextStyle(fontSize: 34, fontWeight: FontWeight.bold)),
                const CircleAvatar(radius: 22, backgroundColor: Color(0xFFE5E5EA)),
              ],
            ),
          ),
          if (pinnedPosts.isNotEmpty) ...[
            _buildSectionHeader("Pinned"),
            _buildPinnedCarousel(pinnedPosts),
          ],
        ],
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
    // Convert to simple Article for the detail sheet
    final article = Article(
      title: post.title,
      subtitle: post.subtitle,
      imagePath: post.imagePath,
      content: post.content,
    );
    return GestureDetector(
      onTap: () => _showArticleSheet(article),
      child: Container(
        height: isPinned ? 150 : 250,
        margin: isPinned ? const EdgeInsets.only(right: 16) : const EdgeInsets.fromLTRB(24, 0, 24, 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: isPinned ? 1 : 2,
              child: ClipRRect(
                borderRadius: isPinned ? BorderRadius.circular(20) : const BorderRadius.vertical(top: Radius.circular(20)),
                child: Image.asset(article.imagePath!, fit: BoxFit.cover),
              ),
            ),
            if (!isPinned)
              Expanded(
                flex: 1,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(article.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(article.subtitle, style: TextStyle(color: Colors.grey.shade600)),
                    ],
                  ),
                ),
              )
          ],
        ),
      ),
    );
  }

  Widget _buildGoToTodayButton() {
    return ElevatedButton.icon(
      onPressed: _scrollToToday,
      icon: const Icon(Icons.arrow_upward, size: 16),
      label: const Text('Today'),
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.black, backgroundColor: Colors.white,
        shape: const StadiumBorder(),
        elevation: 4,
        shadowColor: Colors.black.withOpacity(0.2),
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

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24.0, 0, 24.0, 16.0),
      child: Text(
        title,
        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.grey.shade600),
      ),
    );
  }
}
