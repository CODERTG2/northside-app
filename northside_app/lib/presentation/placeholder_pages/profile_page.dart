// lib/presentation/placeholder_pages/profile_page.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:figma_squircle/figma_squircle.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/design_constants.dart';

import '../../models/article.dart';
import '../../widgets/article_detail_draggable_sheet.dart';
import '../../widgets/webview_sheet.dart';
import '../../widgets/login_sheet.dart';
import '../../core/utils/logger.dart';

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
    content: '''
Stampede: Northside App
Version 1.0.0
  
Developed by the Sarveshwaraan Swaminathan ('26) & Tanmay Garg ('26).
  
Special thanks to all contributors, the school community, Claude, and Gemini.
  
Contact us:
- Email: stampede.ncp@gmail.com
- Github: https://github.com/CODERTG2/northside-app
- Instagram: @ncpstampede

If you encounter any bugs or would like to suggest anything please do so on this [Google Form](https://forms.gle/sQKcGmnXk2KFjkC79) or on [Github](https://github.com/CODERTG2/northside-app).'''
);

Future<void> _launchInExternalBrowser(String url) async {
  try {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      AppLogger.warning('Could not launch URL: $url');
      Get.snackbar(
        'Error',
        'Unable to open link in external browser',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    }
  } catch (e) {
    AppLogger.error('Error launching URL in external browser', e);
    Get.snackbar(
      'Error',
      'Error opening link in external browser',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  final List<ProfileOption> _options = const [
    ProfileOption(
      title: 'App Info',
      subtitle: 'Version, credits, and more',
      actionType: ProfileActionType.info,
    ),
    ProfileOption(
      title: 'Events & Announcement Submissions',
      subtitle: 'Submit events and announcements',
      actionType: ProfileActionType.link,
      url: 'https://forms.gle/Ff6RoPK9WqQhBEyu9',
    ),
    ProfileOption(
      title: 'Your Athletic Account',
      subtitle: 'Login with your athletic account',
      actionType: ProfileActionType.link,
      url: 'https://ncp-ar.rschooltoday.com/oar',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      body: SafeArea(
        child: ListView(
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
                      ArticleDetailDraggableSheet(article: appInfoArticle),
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      useRootNavigator: false,
                      enableDrag: true,
                    );
                  } else if (option.actionType == ProfileActionType.link && option.url != null) {
                    _launchInExternalBrowser(option.url!);
                  } else if (option.actionType == ProfileActionType.login) {
                    Get.bottomSheet(
                      const LoginSheet(),
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      useRootNavigator: false,
                      enableDrag: true,
                    );
                  }
                },
              );
            }).toList(),
          ],
        ),
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
        Text('User', style: GoogleFonts.inter(fontSize: nameFontSize, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
        SizedBox(height: screenWidth * 0.01),
        Text('ID', style: TextStyle(fontSize: infoFontSize, color: Colors.black), maxLines: 1, overflow: TextOverflow.ellipsis),
        SizedBox(height: screenWidth * 0.01),
        Text('Northside College Prep', style: TextStyle(fontSize: infoFontSize, color: Colors.black), maxLines: 1, overflow: TextOverflow.ellipsis),
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
        decoration: ShapeDecoration(
          color: Colors.white,            shape: SmoothRectangleBorder(
              borderRadius: SmoothBorderRadius(
                cornerRadius: DesignConstants.get24Radius(context),
                cornerSmoothing: 1.0,
              ),
            ),
          shadows: DesignConstants.standardShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: GoogleFonts.inter(fontSize: titleFontSize, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
            SizedBox(height: screenWidth * 0.01),
            Text(subtitle, style: TextStyle(fontSize: subtitleFontSize, color: Colors.black), maxLines: 1, overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }
}
