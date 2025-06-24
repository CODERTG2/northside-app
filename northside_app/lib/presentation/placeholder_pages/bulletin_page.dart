// lib/presentation/placeholder_pages/bulletin_page.dart

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:sticky_headers/sticky_headers.dart';

import '../../controllers/bulletin_controller.dart';
import '../../core/theme/app_theme.dart';
import '../../models/article.dart';
import '../../models/bulletin_post.dart';
import '../../widgets/article_detail_sheet.dart';
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
  double _lastSheetExtent = 0.55;
  final double _initialSheetExtent = 0.55;

  // For drag handle
  final DraggableScrollableController _sheetController = DraggableScrollableController();
  double? dragStartExtent;
  bool _isDraggingHandle = false;

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
    // Find the index of 'Today' in the keys
    final keys = grouped.keys.toList();
    _todaySectionIndex = keys.indexOf('Today');
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
    // Calculate offset so that the 'Today' section is at the very top
    for (int i = 0; i < _todaySectionIndex!; i++) {
      offset += 56; // Date header height
      offset += (_groupedPosts[keys[i]]!.length) * (280 + 16); // Card height + card margin
    }
    // Do NOT subtract any value here; this ensures 'Today' is at the top
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

  void _showArticleSheet(BulletinPost post) {
    Get.bottomSheet(
      SafeArea(
        child: ArticleDetailSheet(
          article: Article(
            title: post.title,
            subtitle: post.subtitle,
            imagePath: post.imagePath,
            content: post.content,
          ),
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
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
    final pinnedPosts = controller.pinnedPosts;
    final dateKeys = _groupedPosts.keys.toList();
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;
    final double topSpacer = 24;
    final double betweenSpacer = 0; // Set to 0 to remove gap

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

    double minSheetExtent;
    // Always use a minimal fallback until real heights are measured
    if (pinnedPosts.isNotEmpty && _calculatedSheetExtent != null) {
      minSheetExtent = _calculatedSheetExtent!;
    } else {
      minSheetExtent = 0.1; // Minimal fallback, will be updated after layout
    }

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
              // Remove the betweenSpacer from the layout
              // SizedBox(height: betweenSpacer),
            ],
          ),
          // DraggableScrollableSheet overlays lower part only
          Align(
            alignment: Alignment.bottomCenter,
            child: DraggableScrollableSheet(
              controller: _sheetController,
              initialChildSize: minSheetExtent, // dynamically calculated
              minChildSize: minSheetExtent,     // dynamically calculated
              maxChildSize: 0.9,
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
                    // Remove the top margin to close the gap
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
                  // Remove the top margin to close the gap
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
                          _isDraggingHandle = true;
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
                          _isDraggingHandle = false;
                          dragStartExtent = null;
                          // Snap to min extent if swiped down fast
                          if (details.primaryVelocity != null && details.primaryVelocity! > 500) {
                            _sheetController.animateTo(minSheetExtent, duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
                          }
                          // No need to trigger scrollToTodaySection here; handled by controller listener
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
                          padding: const EdgeInsets.only(top: 0, bottom: 24),
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
  }

  Widget _buildSectionHeader(String title, {Key? key}) {
    final double screenWidth = MediaQuery.of(context).size.width;
    return Padding(
      key: key,
      padding: EdgeInsets.fromLTRB(screenWidth * 0.06, 0, screenWidth * 0.06, screenWidth * 0.04),
      child: Text(
        title,
        style: TextStyle(fontSize: screenWidth * 0.055, fontWeight: FontWeight.bold, color: Colors.grey.shade600),
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
      SafeArea(
        child: ArticleDetailSheet(
          article: Article(
            title: post.title,
            subtitle: post.subtitle,
            imagePath: post.imagePath,
            content: post.content,
          ),
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
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
                    fit: BoxFit.cover,
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
                          style: TextStyle(fontSize: fontSizeTitle, fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: screenWidth * 0.03),
                        Row(
                          children: [
                            Icon(Icons.calendar_today_outlined, size: iconSize, color: Colors.grey),
                            SizedBox(width: screenWidth * 0.02),
                            Expanded(
                              child: Text(
                                post.subtitle,
                                style: TextStyle(fontSize: fontSizeSubtitle, color: Colors.grey.shade700),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Icon(Icons.more_horiz, size: iconSize * 1.2, color: Colors.grey),
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
      SafeArea(
        child: ArticleDetailSheet(
          article: Article(
            title: post.title,
            subtitle: post.subtitle,
            imagePath: post.imagePath,
            content: post.content,
          ),
        ),
      ),
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
                fit: BoxFit.cover,
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
                    style: TextStyle(fontSize: fontSizeTitle, fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: screenWidth * 0.01),
                  Text(
                    post.subtitle,
                    style: TextStyle(fontSize: fontSizeSubtitle, color: Colors.grey.shade700),
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
