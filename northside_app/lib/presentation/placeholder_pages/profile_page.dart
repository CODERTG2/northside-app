// lib/presentation/placeholder_pages/profile_page.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../models/article.dart';
import '../../widgets/article_detail_sheet.dart';
import '../../widgets/webview_sheet.dart';
import '../../widgets/login_sheet.dart';

// Data Model with different action types
enum ProfileActionType { info, link, login }

class ProfileOption {
  const ProfileOption({
    required this.title,
    required this.subtitle,
    required this.actionType,
    this.url,
  });
  final String title;
  final String subtitle;
  final ProfileActionType actionType;
  final String? url;
}

// Add this at the top-level, after imports and before ProfilePage
const Article appInfoArticle = Article(
  title: 'App Info',
  subtitle: 'Version, credits, and more',
  content: 'Northside App\nVersion 1.0.0\n\nDeveloped by the Northside Team.\n\nSpecial thanks to all contributors and the school community.',
);

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  final List<ProfileOption> _options = const [
    ProfileOption(
      title: 'App Info',
      subtitle: 'Version, credits, and more',
      actionType: ProfileActionType.info,
    ),
    ProfileOption(
      title: 'Your Athletic Profile',
      subtitle: 'Apply to sports teams with your profile',
      actionType: ProfileActionType.link,
      url: 'https://www.google.com',
    ),
    ProfileOption(
      title: 'Your Athletic Account',
      subtitle: 'Login with your athletic account',
      actionType: ProfileActionType.link,
      url: 'https://ncp-ar.rschooltoday.com/oar',
    ),
    ProfileOption(
      title: 'Flex Account',
      subtitle: 'Link your flex account to pick flexes',
      actionType: ProfileActionType.login,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      body: ListView(
        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.06).copyWith(bottom: screenHeight * 0.12),
        children: [
          SizedBox(height: screenHeight * 0.05),
          _buildProfileHeader(context),
          SizedBox(height: screenHeight * 0.04),
          ..._options.map((option) {
            return _buildInfoCard(
              context: context,
              title: option.title,
              subtitle: option.subtitle,
              onTap: () {
                if (option.actionType == ProfileActionType.info) {
                  Get.bottomSheet(
                    ArticleDetailSheet(article: appInfoArticle),
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                  );
                } else if (option.actionType == ProfileActionType.link && option.url != null) {
                  Get.bottomSheet(
                    WebViewSheet(url: option.url!),
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                  );
                } else if (option.actionType == ProfileActionType.login) {
                  Get.bottomSheet(
                    const LoginSheet(),
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                  );
                }
              },
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double avatarSize = screenWidth * 0.25;
    final double iconSize = screenWidth * 0.15;
    final double nameFontSize = screenWidth * 0.07;
    final double infoFontSize = screenWidth * 0.045;
    return Column(
      children: [
        Container(
          width: avatarSize,
          height: avatarSize,
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.black, width: 3),
          ),
          child: Icon(Icons.person, size: iconSize, color: Colors.black),
        ),
        SizedBox(height: screenWidth * 0.04),
        Text('John', style: TextStyle(fontSize: nameFontSize, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
        SizedBox(height: screenWidth * 0.01),
        Text('60546723', style: TextStyle(fontSize: infoFontSize, color: Colors.grey.shade600), maxLines: 1, overflow: TextOverflow.ellipsis),
        SizedBox(height: screenWidth * 0.01),
        Text('Northside College Prep', style: TextStyle(fontSize: infoFontSize, color: Colors.grey.shade600), maxLines: 1, overflow: TextOverflow.ellipsis),
      ],
    );
  }

  Widget _buildInfoCard({required BuildContext context, required String title, required String subtitle, required VoidCallback onTap}) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double titleFontSize = screenWidth * 0.045;
    final double subtitleFontSize = screenWidth * 0.037;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: screenWidth * 0.03),
        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05, vertical: screenWidth * 0.04),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(fontSize: titleFontSize, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
            SizedBox(height: screenWidth * 0.01),
            Text(subtitle, style: TextStyle(fontSize: subtitleFontSize, color: Colors.grey.shade600), maxLines: 1, overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }
}
