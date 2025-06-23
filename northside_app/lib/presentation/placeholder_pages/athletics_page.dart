// lib/presentation/placeholder_pages/athletics_page.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../athletics/all_sports_page.dart';
import '../athletics/sport_detail_page.dart';
import '../../models/article.dart';
import '../../widgets/article_detail_sheet.dart';
import '../../widgets/shared_header.dart';
import '../../core/utils/app_colors.dart';

// NEW: Import the webview sheet
import '../../widgets/webview_sheet.dart';

class AthleticsPage extends StatelessWidget {
  const AthleticsPage({super.key});

  final List<Article> _athleticsArticles = const [
    Article(
      title: 'Girls Softball make it to state',
      subtitle: 'For the first time in 2 years...',
      imagePath: 'assets/images/softball_image.png',
      content: 'An incredible season culminates in a historic state championship appearance. The team\'s hard work and dedication have paid off, inspiring the entire school community. Go Mustangs!',
    ),
    Article(
      title: 'Soccer Team Wins City Finals',
      subtitle: 'A thrilling 2-1 victory!',
      imagePath: 'assets/images/softball_image.png',
      content: 'In a nail-biting final match, our varsity soccer team clinched the city championship with a goal in the final minutes. Congratulations to the players and coaches!',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 120),
        children: [
          const SharedHeader(title: 'Athletics'),
          const SizedBox(height: 16),
          _buildNewsCarousel(),
          const SizedBox(height: 32),
          _buildSectionHeader(context, 'Sports', () => Get.to(() => const AllSportsPage())),
          const SizedBox(height: 16),
          _buildSportsGrid(),
          const SizedBox(height: 24),
          _buildRegisterButton(),
        ],
      ),
    );
  }

  // --- WIDGET WITH THE FIX ---
  Widget _buildRegisterButton() {
    // Define the URL for the registration page.
    const String registrationUrl = 'https://ncp-ar.rschooltoday.com/oar';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      // FIX: Wrapped the button's container in a GestureDetector.
      child: GestureDetector(
        onTap: () {
          // This opens the webview sheet when the card is tapped.
          Get.bottomSheet(
            const WebViewSheet(url: registrationUrl),
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.add_circle_outline, color: AppColors.primaryBlue),
              const SizedBox(width: 8),
              const Text(
                'Register for a sport',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.primaryBlue),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- All other widgets below are unchanged but included for completeness ---

  Widget _buildNewsCarousel() {
    return SizedBox(
      height: 280,
      child: PageView.builder(
        controller: PageController(viewportFraction: 0.85),
        clipBehavior: Clip.none,
        itemCount: _athleticsArticles.length,
        itemBuilder: (context, index) {
          final article = _athleticsArticles[index];
          return GestureDetector(
            onTap: () {
              Get.bottomSheet(
                ArticleDetailSheet(article: article),
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
              );
            },
            child: _NewsCard(article: article),
          );
        },
      ),
    );
  }

  Widget _buildSportsGrid() {
    final sports = ['Baseball', 'Cross Country', 'Lacrosse', 'Soccer'];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 2.5,
        ),
        itemCount: sports.length,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          final sportName = sports[index];
          return _SportButton(
            name: sportName,
            onTap: () => Get.to(() => SportDetailPage(sportName: "Men's $sportName")),
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, VoidCallback onViewAll) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey.shade600),
          ),
          GestureDetector(
            onTap: onViewAll,
            child: Row(
              children: [
                const Text(
                  'View All',
                  style: TextStyle(fontSize: 14, color: AppColors.primaryBlue, fontWeight: FontWeight.w500),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.arrow_forward_ios, size: 12, color: AppColors.primaryBlue),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NewsCard extends StatelessWidget {
  const _NewsCard({required this.article});
  final Article article;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              child: Image.asset(article.imagePath!, fit: BoxFit.cover, width: double.infinity),
            ),
          ),
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(article.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold), maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Text(article.subtitle, style: TextStyle(fontSize: 14, color: Colors.grey.shade600), maxLines: 1, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SportButton extends StatelessWidget {
  const _SportButton({required this.name, required this.onTap});
  final String name;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Center(
          child: Text(
            name,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }
}
