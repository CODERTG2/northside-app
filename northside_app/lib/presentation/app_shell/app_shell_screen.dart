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
import '../../core/theme/app_theme.dart';

class AppShellScreen extends GetView<AppShellController> {
  const AppShellScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // This list of pages is now correct and will match the new nav bar.
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

  // --- DEFINITIVELY PROPORTIONAL FLOATING NAVIGATION BAR ---
  Widget _buildFloatingM3NavBar(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final double navBarHeight = screenSize.width * 0.14; // Responsive: 14% of width
    final double iconSize = navBarHeight * 0.42; // Responsive icon size
    final double innerPaddingHorizontal = navBarHeight * 0.34; // Proportional side padding
    final double innerPaddingVertical = navBarHeight * 0.15; // Proportional top/bottom padding
    return Container(
      // This outer container defines the full width and shadow of the floating pill.
      margin: EdgeInsets.fromLTRB(AppTheme.horizontalPadding, 0, AppTheme.horizontalPadding, screenSize.height * 0.04),
      height: navBarHeight,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(100), // Pill shape
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 20,
            spreadRadius: -2,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(100), // Pill shape
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15.0, sigmaY: 15.0),
          child: Container(
            color: const Color(0xFFF9F9F9).withOpacity(0.85),
            padding: EdgeInsets.symmetric(horizontal: innerPaddingHorizontal, vertical: innerPaddingVertical),
            child: Center(
              child: NavigationBar(
                backgroundColor: Colors.transparent, // Lets the blur show through.
                elevation: 0, // The outer container handles the shadow.
                indicatorColor: Theme.of(context).colorScheme.primary,
                selectedIndex: controller.navBarIndex.value,
                onDestinationSelected: controller.changePage,
                labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
                destinations: <Widget>[
                  NavigationDestination(
                    selectedIcon: Icon(Icons.home, color: Colors.white, size: iconSize),
                    icon: Icon(Icons.home_outlined, color: Colors.black87, size: iconSize),
                    label: 'Home',
                  ),
                  NavigationDestination(
                    selectedIcon: Icon(Icons.sports_basketball, color: Colors.white, size: iconSize),
                    icon: Icon(Icons.sports_basketball_outlined, color: Colors.black87, size: iconSize),
                    label: 'Athletics',
                  ),
                  NavigationDestination(
                    selectedIcon: Icon(Icons.calendar_month, color: Colors.white, size: iconSize),
                    icon: Icon(Icons.calendar_month_outlined, color: Colors.black87, size: iconSize),
                    label: 'Events',
                  ),
                  NavigationDestination(
                    selectedIcon: Icon(Icons.article, color: Colors.white, size: iconSize),
                    icon: Icon(Icons.article_outlined, color: Colors.black87, size: iconSize),
                    label: 'Bulletin',
                  ),
                  NavigationDestination(
                    selectedIcon: Icon(Icons.person, color: Colors.white, size: iconSize),
                    icon: Icon(Icons.person_outline, color: Colors.black87, size: iconSize),
                    label: 'Profile',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
