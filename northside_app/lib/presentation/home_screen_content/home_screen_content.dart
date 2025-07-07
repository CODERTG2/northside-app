// lib/presentation/home_screen_content/home_screen_content.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:figma_squircle/figma_squircle.dart';
import 'package:google_fonts/google_fonts.dart';
import 'home_screen_content_controller.dart';
import '../app_shell/app_shell_controller.dart';
import '../placeholder_pages/hoofbeat_page.dart';
import '../../models/article.dart';
import '../../widgets/article_detail_draggable_sheet.dart';
import '../../core/design_constants.dart';
import '../../widgets/shared_header.dart';
import '../../controllers/bulletin_controller.dart';

class HomeScreenContent extends GetView<HomeScreenContentController> {
  const HomeScreenContent({super.key});

  @override
  Widget build(BuildContext context) {
    final BulletinController bulletinController = Get.find();
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFFFF6B6B), // Red
                  Color(0xFF4A90E2), // True blue (less green)
                ],
                stops: [0.0, 1.0],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  Colors.transparent,
                  Color(0xFFF2F2F7).withOpacity(0.03),
                  Color(0xFFF2F2F7).withOpacity(0.07),
                  Color(0xFFF2F2F7).withOpacity(0.15),
                  Color(0xFFF2F2F7).withOpacity(0.25),
                  Color(0xFFF2F2F7).withOpacity(0.4),
                  Color(0xFFF2F2F7).withOpacity(0.6),
                  Color(0xFFF2F2F7).withOpacity(0.8),
                  Color(0xFFF2F2F7).withOpacity(0.95),
                  Color(0xFFF2F2F7),
                ],
                stops: [0.0, 0.12, 0.18, 0.25, 0.32, 0.38, 0.42, 0.45, 0.47, 0.49, 0.5],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          ListView(
            padding: EdgeInsets.only(bottom: 120),
            children: [
              const SharedHeader(title: 'Home'),
              SizedBox(height: MediaQuery.of(context).size.height * 0.02), // 2% of screen height for consistent spacing
              _buildQuickActions(),
              SizedBox(height: MediaQuery.of(context).size.height * 0.04), // 4% of screen height
              Obx(() => _buildEventsCarousel(context, bulletinController)),
              SizedBox(height: MediaQuery.of(context).size.height * 0.02), // 2% of screen height
              Obx(() => _buildPageIndicator(bulletinController)),
            ],
          ),
        ],
      ),
    );
  }

  // --- WIDGET WITH THE FIX ---
  Widget _buildQuickActions() {
    final AppShellController appShellController = Get.find();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      margin: EdgeInsets.zero,
      child: GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.zero,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 2.7,
        children: [
          _QuickActionButton(iconWidget: const Icon(Icons.sports_basketball, color: Color(0xFFFF6B35), size: 26), label: 'Athletics', onTap: () => appShellController.changePage(1)),
          _QuickActionButton(iconWidget: const Icon(Icons.calendar_today, color: Color(0xFF4285F4), size: 26), label: 'Events', onTap: () => appShellController.changePage(2)),
          _QuickActionButton(iconWidget: const Icon(Icons.article, color: Color(0xFF34A853), size: 26), label: 'HoofBeat', onTap: () => Get.to(() => const HoofBeatPage())),
          // FIX: The label is now "Bulletin", the icon is updated, and it correctly navigates to index 3.
          _QuickActionButton(iconWidget: const Icon(Icons.campaign, color: Color(0xFFEA4335), size: 26), label: 'Bulletin', onTap: () => appShellController.changePage(3)),
        ],
      ),
    );
  }

  Widget _buildEventsCarousel(BuildContext context, BulletinController bulletinController) {
    final events = bulletinController.upcomingEvents;
    final double screenHeight = MediaQuery.of(context).size.height;
    final double carouselHeight = screenHeight * 0.4; // 40% of screen height
    
    if (events.isEmpty) {
      return SizedBox(
        height: carouselHeight,
        child: Center(
          child: bulletinController.isLoading 
            ? const CircularProgressIndicator()
            : Container(
                margin: const EdgeInsets.symmetric(horizontal: 24.0),
                padding: const EdgeInsets.all(20),
                decoration: ShapeDecoration(
                  color: Colors.white.withOpacity(0.9),
                  shape: SmoothRectangleBorder(
                    borderRadius: SmoothBorderRadius(
                      cornerRadius: 32,
                      cornerSmoothing: 1.0,
                    ),
                  ),
                  shadows: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1), // Reduced from 0.25 to 0.1 for subtlety
                      blurRadius: 60,
                      offset: const Offset(0, 10),
                      spreadRadius: 0, // Reduced from 2 to 0 for cleaner shadow
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.announcement_outlined, size: 48, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      'No Recent Announcements',
                      style: GoogleFonts.inter(fontSize: MediaQuery.of(context).size.width * 0.045, fontWeight: FontWeight.bold, color: Colors.black),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Check back later for updates!',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
        ),
      );
    }
    
    // Set the event count for infinite scroll calculation
    controller.setEventCount(events.length);
    
    // For single event, don't enable infinite scroll
    if (events.length == 1) {
      return SizedBox(
        height: carouselHeight,
        child: PageView.builder(
          controller: controller.pageController,
          itemCount: 1,
          clipBehavior: Clip.none,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            final post = events[0];
            final article = Article(
              title: post.title,
              subtitle: post.subtitle,
              imagePath: post.imagePath,
              content: post.content,
            );
            return GestureDetector(
              onTap: () {
                Get.bottomSheet(
                  ArticleDetailDraggableSheet(article: article),
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  useRootNavigator: false,
                  enableDrag: true,
                );
              },
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 24.0),
                child: _buildEventCard(context, article),
              ),
            );
          },
        ),
      );
    }
    
    // For multiple events, enable infinite scroll
    return SizedBox(
      height: carouselHeight,
      child: PageView.builder(
        controller: PageController(
          initialPage: controller.getVirtualIndex(0),
        ),
        itemCount: null, // Infinite
        clipBehavior: Clip.none,
        physics: const BouncingScrollPhysics(),
        onPageChanged: controller.onPageChanged,
        itemBuilder: (context, index) {
          final actualIndex = index % events.length;
          final post = events[actualIndex];
          final article = Article(
            title: post.title,
            subtitle: post.subtitle,
            imagePath: post.imagePath,
            content: post.content,
          );
          return GestureDetector(
            onTap: () {
              Get.bottomSheet(
                ArticleDetailDraggableSheet(article: article),
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                useRootNavigator: false,
                enableDrag: true,
              );
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 24.0),
              child: _buildEventCard(context, article),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEventCard(BuildContext context, Article article) {
    final double screenHeight = MediaQuery.of(Get.context!).size.height;
    final double carouselHeight = screenHeight * 0.4; // 40% of screen height
    final double imageHeight = carouselHeight * 0.70; // 70% of carousel height for image
    
    return Container(
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: SmoothRectangleBorder(
          borderRadius: SmoothBorderRadius(
            cornerRadius: DesignConstants.get32Radius(context),
            cornerSmoothing: 1.0,
          ),
        ),
        shadows: DesignConstants.standardShadow,
      ),                    child: ClipSmoothRect(
                      radius: SmoothBorderRadius(
                        cornerRadius: DesignConstants.get32Radius(context),
                        cornerSmoothing: 1.0,
                      ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: imageHeight, // Dynamic height based on screen size
              padding: const EdgeInsets.only(top: 17.0, bottom: 0.0),
              child: article.imagePath != null 
                ? Image.asset(
                    article.imagePath!, 
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey.shade200,
                        child: const Center(
                          child: Icon(
                            Icons.event,
                            size: 48,
                            color: Colors.grey,
                          ),
                        ),
                      );
                    },
                  )
                : Container(
                    color: Colors.grey.shade200,
                    child: const Center(
                      child: Icon(
                        Icons.event,
                        size: 48,
                        color: Colors.grey,
                      ),
                    ),
                  ),
            ),
            Transform.translate(
              offset: const Offset(0, -1),
              child: Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(article.title, style: GoogleFonts.inter(fontSize: MediaQuery.of(context).size.width * 0.045, fontWeight: FontWeight.bold, color: Colors.black), maxLines: 1, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            article.subtitle,
                            style: const TextStyle(fontSize: 14, color: Colors.grey),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const Icon(Icons.more_horiz, size: 20, color: Colors.grey),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPageIndicator(BulletinController bulletinController) {
    final events = bulletinController.upcomingEvents;
    if (events.isEmpty || events.length == 1) {
      return const SizedBox.shrink(); // Don't show indicator if no events or single event
    }
    
    return Obx(() {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(events.length, (index) {
          final currentIndex = controller.currentPageIndex.value;
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 4.0),
            width: 8.0,
            height: 8.0,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: currentIndex == index ? const Color(0xFF333333) : Colors.grey.withOpacity(0.4),
            ),
          );
        }),
      );
    });
  }
}

class _QuickActionButton extends StatelessWidget {
  const _QuickActionButton({required this.iconWidget, required this.label, required this.onTap});
  final Widget iconWidget;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: ShapeDecoration(
          color: Colors.white,
          shape: SmoothRectangleBorder(
            borderRadius: SmoothBorderRadius(
              cornerRadius: DesignConstants.get24Radius(context),
              cornerSmoothing: 1.0,
            ),
          ),
          shadows: DesignConstants.standardShadow,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            iconWidget,
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                label,
                style: GoogleFonts.inter(fontSize: MediaQuery.of(context).size.width * 0.045, fontWeight: FontWeight.bold, color: Colors.black),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
