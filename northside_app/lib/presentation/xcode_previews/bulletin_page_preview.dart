// lib/presentation/xcode_previews/bulletin_page_preview.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../placeholder_pages/bulletin_page.dart';
import '../../controllers/bulletin_controller.dart';
import '../../models/bulletin_post.dart';

/// Preview wrapper for BulletinPage to work with Xcode previews
/// This provides mock data and proper initialization for preview mode
class BulletinPagePreview extends StatelessWidget {
  const BulletinPagePreview({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize GetX and controller with mock data for preview
    return GetMaterialApp(
      title: 'Bulletin Page Preview',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const BulletinPagePreviewWrapper(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class BulletinPagePreviewWrapper extends StatefulWidget {
  const BulletinPagePreviewWrapper({super.key});

  @override
  State<BulletinPagePreviewWrapper> createState() => _BulletinPagePreviewWrapperState();
}

class _BulletinPagePreviewWrapperState extends State<BulletinPagePreviewWrapper> {
  @override
  void initState() {
    super.initState();
    _setupMockData();
  }

  void _setupMockData() {
    // Create mock bulletin controller with sample data
    final controller = Get.put(BulletinController(), permanent: true);
    
    // Add mock pinned posts
    final mockPinnedPosts = [
      BulletinPost(
        id: 'pinned1',
        title: 'Homecoming Week 2024',
        subtitle: 'Join us for an exciting week of activities',
        imagePath: 'assets/images/homecoming_bg.png',
        content: 'Homecoming week is here! Join us for a week full of exciting activities...',
        date: DateTime.now().add(const Duration(days: 2)),
        isPinned: true,
      ),
      BulletinPost(
        id: 'pinned2',
        title: 'Spring Sports Tryouts',
        subtitle: 'Registration now open',
        imagePath: 'assets/images/grades_icon.png',
        content: 'Spring sports tryouts are beginning soon. Register now to participate...',
        date: DateTime.now().add(const Duration(days: 5)),
        isPinned: true,
      ),
    ];

    // Add mock regular posts
    final mockRegularPosts = [
      BulletinPost(
        id: 'today1',
        title: 'Today: Student Council Meeting',
        subtitle: 'Room 204 at 3:30 PM',
        imagePath: 'assets/images/flexes_icon.png',
        content: 'Student Council will meet today to discuss upcoming events...',
        date: DateTime.now(),
        isPinned: false,
      ),
      BulletinPost(
        id: 'today2',
        title: 'Math Competition Results',
        subtitle: 'Congratulations to our winners!',
        imagePath: 'assets/images/hoofbeat_icon.png',
        content: 'The results are in for this month\'s math competition...',
        date: DateTime.now(),
        isPinned: false,
      ),
      BulletinPost(
        id: 'tomorrow1',
        title: 'Library Book Fair',
        subtitle: 'Tomorrow 9 AM - 4 PM',
        imagePath: 'assets/images/grades_icon.png',
        content: 'Don\'t miss the annual library book fair tomorrow...',
        date: DateTime.now().add(const Duration(days: 1)),
        isPinned: false,
      ),
      BulletinPost(
        id: 'yesterday1',
        title: 'Basketball Game Recap',
        subtitle: 'Mustangs win 78-65!',
        imagePath: 'assets/images/flexes_icon.png',
        content: 'Our basketball team had an amazing game yesterday...',
        date: DateTime.now().subtract(const Duration(days: 1)),
        isPinned: false,
      ),
    ];

    // Add all mock posts to controller
    final allMockPosts = [...mockPinnedPosts, ...mockRegularPosts];
    
    // Mock the controller data - you may need to adjust this based on your controller implementation
    // controller.updatePosts(allMockPosts);
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(
        child: BulletinPage(),
      ),
    );
  }
}
