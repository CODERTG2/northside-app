// lib/presentation/app_shell/app_shell_screen.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:ui'; // Needed for BackdropFilter

import 'app_shell_controller.dart';
import '../home_screen_content/home_screen_content.dart';
import '../placeholder_pages/athletics_page.dart';
import '../placeholder_pages/profile_page.dart';
import '../placeholder_pages/events_page.dart';
import '../placeholder_pages/bulletin_page.dart';

class AppShellScreen extends GetView<AppShellController> {
  const AppShellScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = <Widget>[
      const HomeScreenContent(),
      const AthleticsPage(),
      const EventsPage(),
      const BulletinPage(),
      const ProfilePage(),
    ];

    return Obx(() => Scaffold(
          body: Stack(
            children: [
              // The main page content
              pages[controller.navBarIndex.value],

              // The floating navigation bar at the bottom
              Align(
                alignment: Alignment.bottomCenter,
                child: _buildFloatingM3NavBar(context),
              ),
            ],
          ),
        ));
  }

  // --- REFINED FLOATING MATERIAL 3 NAVIGATION BAR ---
  Widget _buildFloatingM3NavBar(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 30),
      height: 65,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(50),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 20,
            spreadRadius: -2,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(50),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15.0, sigmaY: 15.0),
          child: NavigationBar(
            height: 65,
            backgroundColor: const Color(0xFFF9F9F9).withOpacity(0.85),
            indicatorColor: const Color(0xFF007AFF),
            selectedIndex: controller.navBarIndex.value,
            onDestinationSelected: controller.changePage,
            labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,

            // FIX: Using Spacers to push the icons into a compact group.
            destinations: const <Widget>[
              Spacer(), // Pushes from the left
              NavigationDestination(
                selectedIcon: Icon(Icons.home, color: Colors.white),
                icon: Icon(Icons.home_outlined, color: Colors.black87),
                label: 'Home',
              ),
              NavigationDestination(
                selectedIcon: Icon(Icons.sports_basketball, color: Colors.white),
                icon: Icon(Icons.sports_basketball_outlined, color: Colors.black87),
                label: 'Athletics',
              ),
              NavigationDestination(
                selectedIcon: Icon(Icons.article, color: Colors.white),
                icon: Icon(Icons.article_outlined, color: Colors.black87),
                label: 'Bulletin',
              ),
              NavigationDestination(
                selectedIcon: Icon(Icons.person, color: Colors.white),
                icon: Icon(Icons.person_outline, color: Colors.black87),
                label: 'Profile',
              ),
              Spacer(), // Pushes from the right
            ],
          ),
        ),
      ),
    );
  }
}
