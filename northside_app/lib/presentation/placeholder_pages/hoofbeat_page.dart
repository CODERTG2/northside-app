// lib/presentation/placeholder_pages/hoofbeat_page.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/article.dart';
import '../../widgets/article_detail_sheet.dart';
import '../../core/utils/app_colors.dart';

class HoofBeatPage extends StatelessWidget {
  const HoofBeatPage({super.key});

  static const List<Article> _topStories = [
    Article(
      title: 'Building Damage: Insights from the Principal',
      subtitle: 'John Appleseed and Mac Pineapple',
      imagePath: 'assets/images/school_building.png',
      content: 'Recent structural issues have been identified in the west wing. The principal assures that student safety is the top priority and repairs are scheduled to begin next week, with minimal disruption to classes.',
    ),
    Article(
      title: 'New Cafeteria Menu Announced',
      subtitle: 'By Jane Doe',
      imagePath: 'assets/images/school_building.png',
      content: 'The school cafeteria has announced a new and improved menu for the upcoming semester, featuring more diverse and healthy options based on student feedback.',
    ),
  ];
  static const List<Article> _trendingStories = [
    Article(title: 'Hopping into Spring: Bunny Bowl 2024', subtitle: 'By John Appleseed', imagePath: 'assets/images/trending_1.png', content: 'The annual Bunny Bowl was a huge success, with students enjoying the friendly competition and spring festivities.'),
    Article(title: '2023/2024 20 Hour Show', subtitle: 'By John Appleseed', imagePath: 'assets/images/trending_2.png', content: 'A recap of the incredible performances and talent showcased during the 20 Hour Show.'),
    Article(title: 'The Grass is Greener on This Side', subtitle: 'By John Appleseed', imagePath: 'assets/images/trending_3.png', content: 'An opinion piece on recent campus beautification projects.'),
  ];
  static const List<Article> _newsItems = [
    Article(title: 'Making a Splash: Men\'s Swim completes season', subtitle: 'By John Appleseed', content: 'The men\'s swim team concluded their season with several personal bests and a strong showing at the regional finals.'),
    Article(title: 'Debate Team Takes First Place', subtitle: 'By Jane Doe', content: 'The debate team has once again brought home the first place trophy from the state championship. Congratulations on a well-argued season!'),
    Article(title: 'New Art Exhibit Opens in Library', subtitle: 'By Art Club', content: 'Come see the latest creations from our talented student artists, now on display in the main library through the end of the month.'),
  ];

  void _showArticleSheet(Article article) {
    Get.bottomSheet(
      ArticleDetailSheet(article: article),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => Get.back(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 40),
        children: [
          _buildHeader(),
          const SizedBox(height: 16),
          _buildTopStoryCarousel(),
          const SizedBox(height: 32),
          _buildSectionHeader("Trending Stories"),
          const SizedBox(height: 16),
          _buildTrendingStories(),
          const SizedBox(height: 32),
          _buildSectionHeader("News"),
          const SizedBox(height: 16),
          _buildNewsList(),
          const SizedBox(height: 32),
          _buildSectionHeader("Polls"),
          const SizedBox(height: 16),
          _buildPollsSection(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'HoofBeat',
            style: TextStyle(fontSize: 34, fontWeight: FontWeight.bold, color: Colors.black),
          ),
          CircleAvatar(
            radius: 22,
            backgroundColor: Color(0xFFE5E5EA),
            child: Icon(Icons.person, color: Colors.black, size: 28),
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

  Widget _buildTopStoryCarousel() {
    return SizedBox(
      height: 300,
      child: PageView.builder(
        controller: PageController(viewportFraction: 0.88),
        clipBehavior: Clip.none,
        itemCount: _topStories.length,
        itemBuilder: (context, index) {
          final article = _topStories[index];
          return GestureDetector(
            onTap: () => _showArticleSheet(article),
            child: _TopStoryCard(article: article),
          );
        },
      ),
    );
  }

  Widget _buildTrendingStories() {
    return SizedBox(
      height: 220,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.only(left: 24),
        clipBehavior: Clip.none,
        itemCount: _trendingStories.length,
        itemBuilder: (context, index) {
          final article = _trendingStories[index];
          return GestureDetector(
            onTap: () => _showArticleSheet(article),
            child: _TrendingStoryCard(article: article),
          );
        },
      ),
    );
  }

  Widget _buildNewsList() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: _newsItems.map((article) {
          return GestureDetector(
            onTap: () => _showArticleSheet(article),
            child: _NewsListItem(article: article),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPollsSection() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.0),
      child: _PollCard(
        question: 'Do You Have Senioritis?',
        options: ['Yes', 'No', 'Maybe'],
      ),
    );
  }
}

class _TopStoryCard extends StatelessWidget {
  const _TopStoryCard({required this.article});
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
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(article.imagePath!, fit: BoxFit.cover),
                  Positioned(
                    bottom: 10,
                    left: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: Colors.red.shade700, borderRadius: BorderRadius.circular(8)),
                      child: const Text('News', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
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
                  Text(article.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold), maxLines: 2),
                  const SizedBox(height: 8),
                  Text(article.subtitle, style: TextStyle(fontSize: 14, color: Colors.grey.shade600), maxLines: 1),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TrendingStoryCard extends StatelessWidget {
  const _TrendingStoryCard({required this.article});
  final Article article;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      margin: const EdgeInsets.only(right: 16.0, bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Image.asset(article.imagePath!, height: 120, width: double.infinity, fit: BoxFit.cover),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(article.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13), maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Text(article.subtitle, style: TextStyle(fontSize: 12, color: Colors.grey.shade600), maxLines: 1),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NewsListItem extends StatelessWidget {
  const _NewsListItem({required this.article});
  final Article article;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(article.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(article.subtitle, style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
        ],
      ),
    );
  }
}

class _PollCard extends StatefulWidget {
  const _PollCard({required this.question, required this.options});
  final String question;
  final List<String> options;

  @override
  State<_PollCard> createState() => _PollCardState();
}

class _PollCardState extends State<_PollCard> {
  String? _selectedOption;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.question, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          ...widget.options.map((option) => _buildPollOption(option)),
        ],
      ),
    );
  }

  Widget _buildPollOption(String option) {
    final isSelected = _selectedOption == option;
    return GestureDetector(
      onTap: () => setState(() => _selectedOption = option),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryBlue.withOpacity(0.1) : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? AppColors.primaryBlue : Colors.transparent, width: 1.5),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
              color: isSelected ? AppColors.primaryBlue : Colors.grey.shade500,
            ),
            const SizedBox(width: 12),
            Text(option, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}
