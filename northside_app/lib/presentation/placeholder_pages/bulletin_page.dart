// lib/presentation/placeholder_pages/bulletin_page.dart

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:sticky_headers/sticky_headers.dart';

import '../../controllers/bulletin_controller.dart';
import '../../core/theme/app_theme.dart';
import '../../models/article.dart';
import '../../models/bulletin_post.dart';
import '../../widgets/article_detail_draggable_sheet.dart';
import '../../widgets/article_detail_sheet.dart';
import '../../widgets/shared_header.dart';
import '../app_shell/app_shell_controller.dart';

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
  double? _lastSheetExtent;
  double? _initialSheetExtent;

  // Calculate responsive sheet extents based on screen dimensions
  double get responsiveInitialExtent {
    if (_initialSheetExtent != null) return _initialSheetExtent!;
    
    final context = this.context;
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    
    // Adjust based on screen aspect ratio and size - balanced to show first card without next date
    double baseExtent = 0.46; // 46% for most devices (increased from 42%)
    
    // For very tall/narrow screens (like iPhone 14 Pro Max), reduce slightly
    if (screenHeight / screenWidth > 2.2) {
      baseExtent = 0.42; // Increased from 0.38
    }
    // For shorter/wider screens (like iPad landscape), keep at base
    else if (screenHeight / screenWidth < 1.5) {
      baseExtent = 0.46; // Increased from 0.42
    }
    
    _initialSheetExtent = baseExtent;
    _lastSheetExtent = baseExtent;
    return baseExtent;
  }

  // For drag handle
  final DraggableScrollableController _sheetController = DraggableScrollableController();
  double? dragStartExtent;
  bool _isDraggingHandle = false;

  final GlobalKey _headerKey = GlobalKey();
  final GlobalKey _sectionHeaderKey = GlobalKey();
  final GlobalKey _carouselKey = GlobalKey();
  double? _calculatedMinExtent;

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
    // If sheet is at the snap-back extent, immediately scroll to Today (no animation)
    final snapBackExtent = _getSnapBackExtent();
    if ((_sheetController.size - snapBackExtent).abs() < 0.01) {
      _scrollToTodaySection(animate: false);
    }
  }

  double _getSnapBackExtent() {
    final initialExtent = responsiveInitialExtent;
    
    // Use calculated min extent if available, otherwise use initial extent
    if (_calculatedMinExtent != null) {
      // Ensure we never cover pinned content by using the max of calculated and initial
      // But cap it at a reasonable maximum to prevent the sheet from being too high
      final screenHeight = MediaQuery.of(context).size.height;
      final screenWidth = MediaQuery.of(context).size.width;
      
      // Make max allowed responsive to screen size, but never exceed initial extent
      double maxAllowed = initialExtent; // Never go above initial extent
      if (screenHeight / screenWidth > 2.2) {
        maxAllowed = (initialExtent * 0.9).clamp(0.3, initialExtent); // 90% of initial for tall screens
      } else if (screenHeight / screenWidth < 1.5) {
        maxAllowed = initialExtent; // Use initial extent for wider screens
      }
      
      final safeExtent = (_calculatedMinExtent! > initialExtent ? initialExtent : _calculatedMinExtent!);
      return safeExtent.clamp(0.1, maxAllowed);
    }
    return initialExtent;
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
    
    // Make inactivity timeout responsive to device type
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    
    // Longer timeout for tablets/larger screens, shorter for phones
    Duration timeoutDuration;
    if (screenWidth > 600 || screenHeight > 900) {
      timeoutDuration = const Duration(seconds: 45); // Tablets get longer timeout
    } else {
      timeoutDuration = const Duration(seconds: 30); // Phones get standard timeout
    }
    
    _inactivityTimer = Timer(timeoutDuration, () {
      _scrollToTodaySection(animate: true);
    });
  }

  void _scrollToTodaySection({bool animate = false}) {
    if (_todaySectionIndex == null || _todaySectionIndex! < 0) return;
    if (_draggableSheetController == null) return;
    double offset = 0;
    final keys = _groupedPosts.keys.toList();
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;
    
    // Calculate dynamic header height based on screen size
    final double dateHeaderHeight = screenWidth * 0.13; // Responsive header height
    final bool isNarrowScreen = screenWidth < 360;
    
    // Calculate actual card height based on the new compact design
    final double cardPadding = (isNarrowScreen ? screenWidth * 0.035 : screenWidth * 0.04) * 2; // top + bottom padding
    final double titleHeight = (isNarrowScreen ? screenWidth * 0.045 : screenWidth * 0.055) * 2.2; // title (2 lines max) with line height
    final double spacingBetween = isNarrowScreen ? screenWidth * 0.015 : screenWidth * 0.02; // spacing between title and subtitle
    final double subtitleHeight = isNarrowScreen ? screenWidth * 0.045 : screenWidth * 0.045; // subtitle row with icon
    final double cardHeight = cardPadding + titleHeight + spacingBetween + subtitleHeight;
    final double cardMargin = isNarrowScreen ? screenWidth * 0.03 : screenWidth * 0.04; // Same as used in _BulletinEventCard
    
    // Calculate offset for the target section
    for (int i = 0; i < _todaySectionIndex!; i++) {
      offset += dateHeaderHeight; // Use responsive header height
      offset += (_groupedPosts[keys[i]]!.length) * (cardHeight + cardMargin);
    }
    
    // Debug information
    print('📍 Scroll to Today Debug:');
    print('   Target section: ${keys.isNotEmpty && _todaySectionIndex! < keys.length ? keys[_todaySectionIndex!] : "N/A"}');
    print('   Card height: ${cardHeight.toStringAsFixed(1)}px');
    print('   Card margin: ${cardMargin.toStringAsFixed(1)}px');
    print('   Date header height: ${dateHeaderHeight.toStringAsFixed(1)}px');
    print('   Calculated offset: ${offset.toStringAsFixed(1)}px');
    
    // Account for ListView padding and ensure perfect visibility
    final double listViewTopPadding = screenWidth * 0.02; // Same as ListView padding
    final double extraBuffer = dateHeaderHeight * 0.8; // Much more aggressive buffer
    final double cardBuffer = cardHeight * 0.2; // Add extra card-based buffer
    offset = (offset - listViewTopPadding - extraBuffer - cardBuffer).clamp(0.0, double.infinity);
    
    print('   ListView top padding: ${listViewTopPadding.toStringAsFixed(1)}px');
    print('   Extra buffer: ${extraBuffer.toStringAsFixed(1)}px');
    print('   Card buffer: ${cardBuffer.toStringAsFixed(1)}px');
    print('   Final offset after adjustments: ${offset.toStringAsFixed(1)}px');
    
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
    final double topSpacer = screenWidth * 0.057; // ~24px at 420px width
    final double betweenSpacer = 0; // Set to 0 to remove gap

    // Calculate dynamic minimum extent to avoid covering pinned section (always present now)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final headerBox = _headerKey.currentContext?.findRenderObject() as RenderBox?;
      final sectionHeaderBox = _sectionHeaderKey.currentContext?.findRenderObject() as RenderBox?;
      final carouselBox = _carouselKey.currentContext?.findRenderObject() as RenderBox?;
      if (headerBox != null && sectionHeaderBox != null && carouselBox != null) {
        final double totalHeight =
          headerBox.size.height +
          topSpacer +
          sectionHeaderBox.size.height +
          carouselBox.size.height +
          screenWidth * 0.038; // Add small buffer (~16px at 420px width)
        final double calculatedMin = (totalHeight / screenHeight).clamp(0.1, 0.5);
        if (_calculatedMinExtent != calculatedMin) {
          setState(() {
            _calculatedMinExtent = calculatedMin;
          });
        }
      }
    });

    final double effectiveMinExtent = _getSnapBackExtent();
    final double effectiveInitialExtent = responsiveInitialExtent;
    
    // Ensure minChildSize <= initialChildSize to prevent Flutter assertion error
    final double safeMinExtent = (effectiveMinExtent > effectiveInitialExtent ? effectiveInitialExtent : effectiveMinExtent) * 0.9;

    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      body: Stack(
        children: [
          // Main header and pinned carousel always visible
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SharedHeader(title: 'Bulletin'),
              SizedBox(height: topSpacer),
              _buildSectionHeader("Pinned", key: _sectionHeaderKey),
              if (pinnedPosts.isNotEmpty) 
                _buildPinnedCarousel(pinnedPosts, key: _carouselKey)
              else
                _buildEmptyPinnedSection(key: _carouselKey),
              // Remove the betweenSpacer from the layout
              // SizedBox(height: betweenSpacer),
            ],
          ),
          // DraggableScrollableSheet overlays lower part only
          Align(
            alignment: Alignment.bottomCenter,
            child: DraggableScrollableSheet(
              controller: _sheetController,
              initialChildSize: effectiveInitialExtent,
              minChildSize: safeMinExtent,
              maxChildSize: 0.9,
              expand: false, // Allow sheet to retract from any scroll position
              builder: (context, scrollController) {
                _draggableSheetController = scrollController;
                // Delay the scroll slightly to ensure the sheet is fully rendered with new compact cards
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  Future.delayed(const Duration(milliseconds: 100), () {
                    _scrollToTodaySection(animate: false);
                  });
                });
                scrollController.removeListener(_onScroll);
                scrollController.addListener(_onScroll);
                if (dateKeys.isEmpty) {
                  return Container(
                    // Remove the top margin to close the gap
                    decoration: BoxDecoration(
                      color: Color(0xFFF2F2F7),
                      borderRadius: BorderRadius.vertical(top: Radius.circular(screenWidth * 0.057)), // ~24px at 420px width
                      boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 20, spreadRadius: -5)],
                    ),
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.all(screenWidth * 0.076), // ~32px at 420px width
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
                  decoration: BoxDecoration(
                    color: Color(0xFFF2F2F7),
                    borderRadius: BorderRadius.vertical(top: Radius.circular(screenWidth * 0.057)), // ~24px at 420px width
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
                            final newExtent = (_sheetController.size - dragDelta / MediaQuery.of(context).size.height).clamp(safeMinExtent, 0.9);
                            _sheetController.jumpTo(newExtent);
                          }
                        },
                        onVerticalDragEnd: (details) {
                          _isDraggingHandle = false;
                          dragStartExtent = null;
                          // Snap to snap-back extent if swiped down fast
                          if (details.primaryVelocity != null && details.primaryVelocity! > 500) {
                            _sheetController.animateTo(_getSnapBackExtent(), duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
                          }
                          // No need to trigger scrollToTodaySection here; handled by controller listener
                        },
                        child: Padding(
                          padding: EdgeInsets.only(top: screenWidth * 0.029, bottom: screenWidth * 0.019), // ~12px, ~8px at 420px width
                          child: Center(
                            child: Container(
                              width: screenWidth * 0.086, // ~36px at 420px width
                              height: screenWidth * 0.012, // ~5px at 420px width
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
                          padding: EdgeInsets.only(
                            top: screenWidth * 0.02, // Small buffer above first card
                            bottom: screenHeight * 0.18, // Responsive bottom padding
                          ),
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
        style: TextStyle(fontSize: screenWidth * 0.055, fontWeight: FontWeight.w900, color: Colors.black),
      ),
    );
  }

  Widget _buildDateHeader(String date) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;
    
    // Make header height responsive to screen size
    final double headerHeight = screenWidth * 0.13; // 13% of screen width
    final double verticalPadding = screenWidth * 0.03;
    final double horizontalPadding = screenWidth * 0.06;
    
    return Container(
      width: double.infinity,
      height: headerHeight,
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: verticalPadding,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFFF2F2F7),
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          date,
          style: TextStyle(
            fontSize: screenWidth * 0.05, 
            fontWeight: FontWeight.bold,
          ),
        ),
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
        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.057), // ~24px at 420px width
        itemCount: posts.length,
        itemBuilder: (context, index) {
          return _PinnedPostCard(post: posts[index]);
        },
      ),
    );
  }

  Widget _buildEmptyPinnedSection({Key? key}) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double carouselHeight = screenWidth * 0.56; // Same height as regular carousel
    return SizedBox(
      key: key,
      height: carouselHeight,
      child: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.057), // ~24px at 420px width
          child: Text(
            'No pinned posts at this time',
            style: TextStyle(
              fontSize: screenWidth * 0.04,
              color: Colors.grey.shade600,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
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
    final bool isNarrowScreen = screenWidth < 360;
    
    return GestureDetector(
      onTap: () => _showArticleSheet(post),
      child: Container(
        width: double.infinity,
        margin: EdgeInsets.fromLTRB(screenWidth * 0.06, 0, screenWidth * 0.06, isNarrowScreen ? screenWidth * 0.03 : screenWidth * 0.04),
        padding: EdgeInsets.all(isNarrowScreen ? screenWidth * 0.035 : screenWidth * 0.04),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppTheme.cardRadius),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 15, offset: const Offset(0, 5))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              post.title,
              style: TextStyle(
                fontSize: isNarrowScreen ? screenWidth * 0.045 : screenWidth * 0.055, 
                fontWeight: FontWeight.w900
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: isNarrowScreen ? screenWidth * 0.015 : screenWidth * 0.02),
            Row(
              children: [
                Icon(
                  Icons.calendar_today_outlined, 
                  size: isNarrowScreen ? screenWidth * 0.04 : screenWidth * 0.045, 
                  color: Colors.black
                ),
                SizedBox(width: screenWidth * 0.02),
                Flexible(
                  child: Text(
                    post.subtitle,
                    style: TextStyle(
                      fontSize: isNarrowScreen ? screenWidth * 0.035 : screenWidth * 0.04,
                      color: Colors.black,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
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