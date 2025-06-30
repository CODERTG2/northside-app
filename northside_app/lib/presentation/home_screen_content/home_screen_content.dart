// lib/presentation/home_screen_content/home_screen_content.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'home_screen_content_controller.dart';
import '../app_shell/app_shell_controller.dart';
import '../placeholder_pages/hoofbeat_page.dart';
import '../../models/article.dart';
import '../../widgets/article_detail_draggable_sheet.dart';
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
                  Color(0xFFFBC8C4), // Vibrant Red
                  Color(0xFFC8DAF5), // Vibrant Blue
                  Colors.white
                ],
                stops: [0.0, 0.4, 0.6],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
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
              Obx(() => _buildEventsCarousel(bulletinController)),
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
          _QuickActionButton(iconWidget: const Icon(Icons.calendar_today_outlined, color: Color(0xFF4285F4), size: 26), label: 'Events', onTap: () => appShellController.changePage(2)),
          _QuickActionButton(iconWidget: const Icon(Icons.article, color: Color(0xFF34A853), size: 26), label: 'HoofBeat', onTap: () => Get.to(() => const HoofBeatPage())),
          // FIX: The label is now "Bulletin", the icon is updated, and it correctly navigates to index 3.
          _QuickActionButton(iconWidget: const Icon(Icons.campaign, color: Color(0xFFEA4335), size: 26), label: 'Bulletin', onTap: () => appShellController.changePage(3)),
        ],
      ),
    );
  }

  Widget _buildEventsCarousel(BulletinController bulletinController) {
    final events = bulletinController.upcomingEvents;
    
    if (events.isEmpty) {
      return SizedBox(
        height: 350,
        child: Center(
          child: bulletinController.isLoading 
            ? const CircularProgressIndicator()
            : Container(
                margin: const EdgeInsets.symmetric(horizontal: 24.0),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.announcement_outlined, size: 48, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      'No Recent Announcements',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
    
    return SizedBox(
      height: 350,
      child: PageView.builder(
        controller: controller.pageController,
        itemCount: events.length,
        clipBehavior: Clip.none,
        physics: const BouncingScrollPhysics(),
        onPageChanged: controller.onPageChanged,
        itemBuilder: (context, index) {
          final post = events[index];
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
              child: _buildEventCard(article),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEventCard(Article article) {
    return Container(
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
              child: article.imagePath != null 
                ? Image.asset(
                    article.imagePath!, 
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey.shade300,
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
                    color: Colors.grey.shade300,
                    child: const Center(
                      child: Icon(
                        Icons.event,
                        size: 48,
                        color: Colors.grey,
                      ),
                    ),
                  ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(article.title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(Icons.calendar_today_outlined, size: 16, color: Colors.grey),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            article.subtitle,
                            style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const Icon(Icons.more_horiz, size: 20, color: Colors.grey),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            'More Details',
                            style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.right,
                          ),
                        ),
                      ],
                    ),
                  ],
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
    if (events.isEmpty) {
      return const SizedBox.shrink(); // Don't show indicator if no events
    }
    
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
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            iconWidget,
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                label,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
