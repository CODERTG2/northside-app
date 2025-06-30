// lib/presentation/placeholder_pages/bulletin_page.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';
import 'package:sticky_headers/sticky_headers.dart';

import '../../controllers/bulletin_controller.dart';
import '../../core/utils/logger.dart';
import '../../models/article.dart';
import '../../models/bulletin_post.dart';
import '../../widgets/article_detail_draggable_sheet.dart';
import '../../widgets/shared_header.dart';

class BulletinPage extends StatefulWidget {
  const BulletinPage({super.key});

  @override
  State<BulletinPage> createState() => _BulletinPageState();
}

class _BulletinPageState extends State<BulletinPage> {
  final BulletinController controller = Get.put(BulletinController(), permanent: true);

  Map<String, List<BulletinPost>> _groupedPosts = {};
  ScrollController? _draggableSheetController;
  int? _todaySectionIndex;
  Timer? _inactivityTimer;
  Timer? _midnightTimer;
  bool _isAutoScrolling = false;
  final double _initialSheetExtent = 0.25; // Start at 75% from bottom

  // For drag handle
  final DraggableScrollableController _sheetController = DraggableScrollableController();
  double? dragStartExtent;

  final GlobalKey _headerKey = GlobalKey();
  final GlobalKey _sectionHeaderKey = GlobalKey();
  final GlobalKey _carouselKey = GlobalKey();
  double? _calculatedSheetExtent;

  bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  @override
  void initState() {
    super.initState();
    _buildGroupedList();
    
    // Listen to changes in the bulletin controller data
    ever(controller.allPostsRx, (_) {
      AppLogger.debug('📰 Bulletin: Controller data changed, rebuilding grouped list...');
      _buildGroupedList();
    });
    
    // Add listener to sheet controller for immediate scroll to Today
    _sheetController.addListener(_onSheetExtentChanged);
    _scheduleMidnightUpdate();
  }

  void _scheduleMidnightUpdate() {
    _midnightTimer?.cancel();
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    final duration = tomorrow.difference(now);
    _midnightTimer = Timer(duration, () {
      _buildGroupedList();
      setState(() {});
      _scheduleMidnightUpdate(); // Reschedule for next midnight
    });
  }

  void _onSheetExtentChanged() {
    // If sheet is at min extent, immediately scroll to Today (no animation)
    if ((_sheetController.size - _initialSheetExtent).abs() < 0.01) {
      _scrollToTodaySection(animate: false);
    }
  }

  void _buildGroupedList() {
    final today = DateTime.now();
    final nonPinnedPosts = controller.allPosts.where((post) => !post.isPinned).toList();
    
    AppLogger.debug('📰 Bulletin: Building grouped list...');
    AppLogger.debug('📰 Bulletin: Total allPosts: ${controller.allPosts.length}');
    AppLogger.debug('📰 Bulletin: Non-pinned posts: ${nonPinnedPosts.length}');
    AppLogger.debug('📰 Bulletin: Today is: $today');
    
    for (int i = 0; i < nonPinnedPosts.length && i < 5; i++) {
      final post = nonPinnedPosts[i];
      AppLogger.debug('📰 Bulletin: Post $i: "${post.title}" on ${post.date}');
    }
    
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
    
    AppLogger.debug('📰 Bulletin: Grouped sections: ${grouped.keys.toList()}');
    for (String key in grouped.keys) {
      AppLogger.debug('📰 Bulletin: Section "$key": ${grouped[key]!.length} posts');
    }
    
    setState(() => _groupedPosts = grouped);
    
    // Find the most relevant section to show (Today, or closest to today)
    final keys = grouped.keys.toList();
    int? targetSectionIndex;
    
    // First try to find 'Today'
    targetSectionIndex = keys.indexOf('Today');
    
    // If no 'Today', try 'Tomorrow'
    if (targetSectionIndex == -1) {
      targetSectionIndex = keys.indexOf('Tomorrow');
    }
    
    // If no 'Tomorrow', try 'Yesterday'
    if (targetSectionIndex == -1) {
      targetSectionIndex = keys.indexOf('Yesterday');
    }
    
    // If none of the above, find the section with date closest to today
    if (targetSectionIndex == -1 && keys.isNotEmpty) {
      int closestIndex = 0;
      Duration closestDifference = Duration.zero;
      
      for (int i = 0; i < keys.length; i++) {
        final sectionPosts = grouped[keys[i]]!;
        if (sectionPosts.isNotEmpty) {
          final sectionDate = sectionPosts.first.date;
          final difference = sectionDate.difference(today).abs();
          
          if (i == 0 || difference < closestDifference) {
            closestIndex = i;
            closestDifference = difference;
          }
        }
      }
      targetSectionIndex = closestIndex;
    }
    
    _todaySectionIndex = targetSectionIndex;
  }

  void _onScroll() {
    if (_isAutoScrolling) return;
    _inactivityTimer?.cancel();
    _inactivityTimer = Timer(const Duration(seconds: 30), () {
      _scrollToTodaySection(animate: true);
    });
  }

  void _scrollToTodaySection({bool animate = false}) {
    if (_todaySectionIndex == null || _todaySectionIndex! < 0) return;
    if (_draggableSheetController == null) return;
    double offset = 0;
    final keys = _groupedPosts.keys.toList();
    // Calculate offset so that the target section is at the very top
    for (int i = 0; i < _todaySectionIndex!; i++) {
      offset += 56; // Date header height
      offset += (_groupedPosts[keys[i]]!.length) * (280 + 16); // Card height + card margin
    }
    // Do NOT subtract any value here; this ensures target section is at the top
    if (offset < 0) offset = 0;
    if (animate) {
      _isAutoScrolling = true;
      _draggableSheetController!.animateTo(
        offset,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      ).then((_) => _isAutoScrolling = false);
    } else {
      _draggableSheetController!.jumpTo(offset);
    }
  }

  @override
  void dispose() {
    _inactivityTimer?.cancel();
    _midnightTimer?.cancel();
    _sheetController.removeListener(_onSheetExtentChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final pinnedPosts = controller.pinnedPosts;
      final dateKeys = _groupedPosts.keys.toList();
      final double screenHeight = MediaQuery.of(context).size.height;
      final double topSpacer = 24;

      // Show loading indicator
      if (controller.isLoading) {
        return Scaffold(
          backgroundColor: const Color(0xFFF2F2F7),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SharedHeader(title: 'Bulletin'),
              const Expanded(
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            ],
          ),
        );
      }

      // Show empty state if no posts
      if (controller.allPosts.isEmpty) {
        return Scaffold(
          backgroundColor: const Color(0xFFF2F2F7),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SharedHeader(title: 'Bulletin'),
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.article_outlined,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No posts available',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Check back later for announcements and events',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }

      // After first frame, measure and set the sheet extent
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (pinnedPosts.isNotEmpty) {
          final headerBox = _headerKey.currentContext?.findRenderObject() as RenderBox?;
          final sectionHeaderBox = _sectionHeaderKey.currentContext?.findRenderObject() as RenderBox?;
          final carouselBox = _carouselKey.currentContext?.findRenderObject() as RenderBox?;
          if (headerBox != null && sectionHeaderBox != null && carouselBox != null) {
            final double totalHeight =
              headerBox.size.height +
              topSpacer +
              sectionHeaderBox.size.height +
              carouselBox.size.height;
            final double minSheetExtent = (totalHeight / screenHeight).clamp(0.1, 0.9);
            if (_calculatedSheetExtent != minSheetExtent) {
              setState(() {
                _calculatedSheetExtent = minSheetExtent;
              });
              // Force the sheet to snap to the new min extent so it never covers the carousel
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _sheetController.jumpTo(minSheetExtent);
              });
            }
          }
        }
      });

      double minSheetExtent = 0.25; // Always start at 75% from bottom (25% from top)

      return Scaffold(
        backgroundColor: const Color(0xFFF2F2F7),
        body: Stack(
          children: [
            // Main header and pinned carousel always visible
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SharedHeader(key: _headerKey, title: 'Bulletin'),
                SizedBox(height: topSpacer),
                if (pinnedPosts.isNotEmpty) ...[
                  _buildSectionHeader("Pinned", key: _sectionHeaderKey),
                  _buildPinnedCarousel(pinnedPosts, key: _carouselKey),
                ],
              ],
            ),
            // DraggableScrollableSheet overlays lower part only
            Align(
              alignment: Alignment.bottomCenter,
              child: DraggableScrollableSheet(
                controller: _sheetController,
                initialChildSize: minSheetExtent, // dynamically calculated
                minChildSize: minSheetExtent,     // dynamically calculated
                maxChildSize: 0.9, // Allow expansion to 90% of screen
                expand: false, // Allow sheet to retract from any scroll position
                builder: (context, scrollController) {
                  _draggableSheetController = scrollController;
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _scrollToTodaySection();
                  });
                  scrollController.removeListener(_onScroll);
                  scrollController.addListener(_onScroll);
                  if (dateKeys.isEmpty) {
                    return Container(
                      decoration: const BoxDecoration(
                        color: Color(0xFFF2F2F7),
                        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 20, spreadRadius: -5)],
                      ),
                      child: Center(
                        child: Padding(
                          padding: EdgeInsets.all(32),
                          child: Text(
                            'No bulletin posts available.',
                            style: Theme.of(context).textTheme.bodyLarge,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    );
                  }
                  return Container(
                    decoration: const BoxDecoration(
                      color: Color(0xFFF2F2F7),
                      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                      boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 20, spreadRadius: -5)],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onVerticalDragStart: (details) {
                            dragStartExtent = _sheetController.size;
                          },
                          onVerticalDragUpdate: (details) {
                            if (dragStartExtent != null) {
                              final dragDelta = details.primaryDelta ?? 0.0;
                              final newExtent = (_sheetController.size - dragDelta / MediaQuery.of(context).size.height).clamp(minSheetExtent, 0.9);
                              _sheetController.jumpTo(newExtent);
                            }
                          },
                          onVerticalDragEnd: (details) {
                            dragStartExtent = null;
                            // Snap to min extent if swiped down fast
                            if (details.primaryVelocity != null && details.primaryVelocity! > 500) {
                              _sheetController.animateTo(minSheetExtent, duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
                            }
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(top: 12, bottom: 8),
                            child: Center(
                              child: Container(
                                width: 36,
                                height: 5,
                                decoration: BoxDecoration(
                                  color: Colors.grey[400],
                                  borderRadius: BorderRadius.circular(2.5),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: ListView.builder(
                            controller: scrollController,
                            padding: EdgeInsets.only(top: 0, bottom: 150 + MediaQuery.of(context).viewPadding.bottom),
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
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildSectionHeader(String title, {Key? key}) {
    final double screenWidth = MediaQuery.of(context).size.width;
    return Padding(
      key: key,
      padding: EdgeInsets.fromLTRB(screenWidth * 0.06, 0, screenWidth * 0.06, screenWidth * 0.04),
      child: Text(
        title,
        style: TextStyle(fontSize: screenWidth * 0.055, fontWeight: FontWeight.w900, color: Colors.black),
      ),
    );
  }

  Widget _buildDateHeader(String date) {
    final double screenWidth = MediaQuery.of(context).size.width;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(screenWidth * 0.06, screenWidth * 0.02, screenWidth * 0.06, screenWidth * 0.02),
      decoration: const BoxDecoration(
        color: Color(0xFFF2F2F7),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
      ),
      child: Text(
        date,
        style: TextStyle(fontSize: screenWidth * 0.05, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildPinnedCarousel(List<BulletinPost> posts, {Key? key}) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double carouselHeight = screenWidth * 0.56; // ~236 on 420px width, proportional
    return SizedBox(
      key: key,
      height: carouselHeight,
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
      ArticleDetailDraggableSheet(article: Article(
        title: post.title,
        subtitle: post.subtitle,
        imagePath: post.imagePath,
        content: post.content,
      )),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useRootNavigator: false,
      enableDrag: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double cardRadius = screenWidth * 0.06;
    final double cardHeight = screenWidth * 0.7;
    final double fontSizeTitle = screenWidth * 0.055;
    final double fontSizeSubtitle = screenWidth * 0.04;
    final double iconSize = screenWidth * 0.045;
    return GestureDetector(
      onTap: () => _showArticleSheet(post),
      child: Padding(
        padding: EdgeInsets.fromLTRB(screenWidth * 0.06, 0, screenWidth * 0.06, screenWidth * 0.04),
        child: Container(
          height: cardHeight,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(cardRadius),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 15, offset: const Offset(0, 5))],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(cardRadius),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  flex: 3,
                  child: Image.asset(
                    post.imagePath!,
                    fit: BoxFit.contain,
                    width: double.infinity,
                    errorBuilder: (context, error, stackTrace) => Container(color: Colors.grey[200]),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(screenWidth * 0.04, screenWidth * 0.04, screenWidth * 0.04, screenWidth * 0.03),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          post.title,
                          style: TextStyle(fontSize: fontSizeTitle, fontWeight: FontWeight.w900),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: screenWidth * 0.03),
                        Row(
                          children: [
                            Icon(Icons.calendar_today_outlined, size: iconSize, color: Colors.black),
                            SizedBox(width: screenWidth * 0.02),
                            Expanded(
                              child: Text(
                                post.subtitle,
                                style: TextStyle(fontSize: fontSizeSubtitle, color: Colors.black),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Icon(Icons.more_horiz, size: iconSize * 1.2, color: Colors.black),
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
      ArticleDetailDraggableSheet(article: Article(
        title: post.title,
        subtitle: post.subtitle,
        imagePath: post.imagePath,
        content: post.content,
      )),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double cardRadius = screenWidth * 0.05;
    final double cardWidth = screenWidth * 0.65;
    final double imageHeight = screenWidth * 0.32;
    final double fontSizeTitle = screenWidth * 0.045;
    final double fontSizeSubtitle = screenWidth * 0.035;
    return GestureDetector(
      onTap: () => _showArticleSheet(post),
      child: Container(
        width: cardWidth,
        margin: EdgeInsets.only(right: screenWidth * 0.04, bottom: screenWidth * 0.01),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(cardRadius),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(cardRadius)),
              child: Image.asset(
                post.imagePath!,
                height: imageHeight,
                width: double.infinity,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => Container(color: Colors.grey[200]),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(screenWidth * 0.03),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    post.title,
                    style: TextStyle(fontSize: fontSizeTitle, fontWeight: FontWeight.w900),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: screenWidth * 0.01),
                  Text(
                    post.subtitle,
                    style: TextStyle(fontSize: fontSizeSubtitle, color: Colors.black),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            SizedBox(height: screenWidth * 0.01),
          ],
        ),
      ),
    );
  }
}
