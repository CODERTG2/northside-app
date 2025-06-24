// lib/presentation/placeholder_pages/athletics_page.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../athletics/all_sports_page.dart';
import '../athletics/sport_detail_page.dart';
import '../../models/article.dart';
import '../../widgets/article_detail_sheet.dart';
import '../../widgets/shared_header.dart';
import '../../core/utils/app_colors.dart';
import '../../core/theme/app_theme.dart';

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
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      body: ListView(
        padding: EdgeInsets.only(bottom: screenHeight * 0.12),
        children: [
          const SharedHeader(
            title: 'Athletics',
          ),
          SizedBox(height: screenHeight * 0.02),
          _buildNewsCarousel(context),
          SizedBox(height: screenHeight * 0.04),
          _buildSectionHeader(context, 'Sports', () => Get.to(() => const AllSportsPage())),
          SizedBox(height: screenHeight * 0.02),
          _buildSportsGrid(context),
          SizedBox(height: screenHeight * 0.03),
          _buildRegisterButton(context),
        ],
      ),
    );
  }

  Widget _buildRegisterButton(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double fontSize = screenWidth * 0.045;
    const String registrationUrl = 'https://ncp-ar.rschooltoday.com/oar';
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.06),
      child: GestureDetector(
        onTap: () {
          Get.bottomSheet(
            const WebViewSheet(url: registrationUrl),
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
          );
        },
        child: Container(
          padding: EdgeInsets.symmetric(vertical: screenWidth * 0.045),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add_circle_outline, color: AppColors.primaryBlue, size: screenWidth * 0.06),
              SizedBox(width: screenWidth * 0.02),
              Text(
                'Register for a sport',
                style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.w600, color: AppColors.primaryBlue),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNewsCarousel(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double cardHeight = screenWidth * 0.7;
    return SizedBox(
      height: cardHeight,
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

  Widget _buildSportsGrid(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double crossAxisSpacing = screenWidth * 0.04;
    final double mainAxisSpacing = screenWidth * 0.04;
    final double childAspectRatio = 2.5;
    final sports = ['Baseball', 'Cross Country', 'Lacrosse', 'Soccer'];
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.06),
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: crossAxisSpacing,
          mainAxisSpacing: mainAxisSpacing,
          childAspectRatio: childAspectRatio,
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
    final double screenWidth = MediaQuery.of(context).size.width;
    final double fontSize = screenWidth * 0.045;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.06),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.w600, color: Colors.grey.shade600),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          GestureDetector(
            onTap: onViewAll,
            child: Row(
              children: [
                Text(
                  'View All',
                  style: TextStyle(fontSize: screenWidth * 0.04, color: AppColors.primaryBlue, fontWeight: FontWeight.w500),
                ),
                SizedBox(width: screenWidth * 0.01),
                Icon(Icons.arrow_forward_ios, size: screenWidth * 0.03, color: AppColors.primaryBlue),
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
    final double screenWidth = MediaQuery.of(context).size.width;
    final double cardRadius = screenWidth * 0.05;
    final double fontSizeTitle = screenWidth * 0.045;
    final double fontSizeSubtitle = screenWidth * 0.035;
    return Container(
      margin: EdgeInsets.only(right: screenWidth * 0.04),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(cardRadius),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(cardRadius)),
              child: Image.asset(article.imagePath!, fit: BoxFit.cover, width: double.infinity),
            ),
          ),
          Expanded(
            flex: 2,
            child: Padding(
              padding: EdgeInsets.all(screenWidth * 0.04),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    article.title,
                    style: TextStyle(fontSize: fontSizeTitle, fontWeight: FontWeight.bold),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: screenWidth * 0.01),
                  Text(
                    article.subtitle,
                    style: TextStyle(fontSize: fontSizeSubtitle, color: Colors.grey.shade600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
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
    final double screenWidth = MediaQuery.of(context).size.width;
    final double fontSize = screenWidth * 0.045;
    final double borderRadius = screenWidth * 0.04;
    final double verticalPadding = screenWidth * 0.04;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: verticalPadding),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Center(
          child: Text(
            name,
            style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.w600),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }
}
