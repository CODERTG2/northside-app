// lib/presentation/home_screen/home_screen.dart

import 'dart:ui';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget  Widget _buildHeader(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double fontSize = screenWidth * 0.07;
    return Padding(
      padding: EdgeInsets.fromLTRB(screenWidth * 0.06, screenWidth * 0.04, screenWidth * 0.04, screenWidth * 0.04),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Home', style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.w900, color: Colors.black), maxLines: 1, overflow: TextOverflow.ellipsis),t HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PageController _pageController = PageController();
  int _currentPageIndex = 0;
  // This variable TRACKS which nav item is selected. It's the key to making it interactive.
  int _navBarIndex = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Stack(
        children: [
          // Layer 1: The correct background gradient.
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFE8A1A1), Color(0xFFADC6E6), Colors.white],
                stops: [0.0, 0.25, 0.4],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          // Layer 2: The main UI content.
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                _buildHeader(context),
                SizedBox(height: screenHeight * 0.025),
                _buildQuickActions(context),
                SizedBox(height: screenHeight * 0.03),
                Expanded(child: _buildEventsCarousel()),
                SizedBox(height: screenHeight * 0.02),
                _buildPageIndicator(screenWidth),
                SizedBox(height: screenHeight * 0.13),
              ],
            ),
          ),
          // Layer 3: The floating navigation bar.
          _buildFloatingNavBar(context, screenWidth, screenHeight),
        ],
      ),
    );
  }

  // THIS IS THE CORRECT, INTERACTIVE FLOATING NAVIGATION BAR.
  Widget _buildFloatingNavBar(BuildContext context, double screenWidth, double screenHeight) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: EdgeInsets.fromLTRB(screenWidth * 0.05, 0, screenWidth * 0.05, screenHeight * 0.04),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(screenWidth * 0.13),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15.0, sigmaY: 15.0),
            child: Container(
              height: screenHeight * 0.08,
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.02),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.85),
                borderRadius: BorderRadius.circular(screenWidth * 0.13),
                border: Border.all(color: Colors.white.withOpacity(0.2)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  // Each item is now built with its index to check for selection.
                  _buildNavItem('Home', 0, screenWidth),
                  _buildNavItem('Athletics', 1, screenWidth),
                  _buildNavItem('Attendance', 2, screenWidth),
                  _buildNavItem('Grades', 3, screenWidth),
                  _buildNavIconItem(Icons.person_outline, 4, screenWidth),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // This helper widget now handles taps to change the state.
  Widget _buildNavItem(String label, int index, double screenWidth) {
    final isSelected = _navBarIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _navBarIndex = index; // Updates the state when tapped.
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04, vertical: screenWidth * 0.02),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF007AFF) : Colors.transparent,
          borderRadius: BorderRadius.circular(screenWidth * 0.05),
        ),
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: screenWidth * 0.045, fontWeight: FontWeight.w600, color: isSelected ? Colors.white : Colors.black),
        ),
      ),
    );
  }

  // This helper widget also handles taps.
  Widget _buildNavIconItem(IconData icon, int index, double screenWidth) {
    final isSelected = _navBarIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _navBarIndex = index; // Updates the state when tapped.
        });
      },
      child: Container(
        padding: EdgeInsets.all(screenWidth * 0.01),
        decoration: BoxDecoration(
          border: isSelected ? Border.all(color: const Color(0xFF007AFF), width: 1.5) : null,
          borderRadius: BorderRadius.circular(screenWidth * 0.025),
        ),
        child: Icon(icon, size: screenWidth * 0.07, color: isSelected ? const Color(0xFF007AFF) : Colors.black),
      ),
    );
  }

  // --- The rest of the file (header, buttons, etc.) is the same. ---

  Widget _buildHeader(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double fontSize = screenWidth * 0.07;
    return Padding(
      padding: EdgeInsets.fromLTRB(screenWidth * 0.06, screenWidth * 0.04, screenWidth * 0.04, screenWidth * 0.04),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Home', style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.w900, color: Colors.black), maxLines: 1, overflow: TextOverflow.ellipsis),
          CircleAvatar(
            radius: screenWidth * 0.06,
            backgroundColor: const Color(0xFF1E1E1E).withOpacity(0.9),
            child: Icon(Icons.person_outline, color: Colors.white, size: screenWidth * 0.07),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double crossAxisSpacing = screenWidth * 0.04;
    final double mainAxisSpacing = screenWidth * 0.04;
    final double childAspectRatio = 2.7;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.06),
      child: GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: crossAxisSpacing,
        mainAxisSpacing: mainAxisSpacing,
        childAspectRatio: childAspectRatio,
        children: [
          _QuickActionButton(iconWidget: Image.asset('assets/images/grades_icon.png', width: screenWidth * 0.08, height: screenWidth * 0.08), label: 'Grades', onTap: () {}),
          _QuickActionButton(iconWidget: Icon(Icons.calendar_today_outlined, color: Color(0xFF4285F4), size: screenWidth * 0.065), label: 'Events', onTap: () {}),
          _QuickActionButton(iconWidget: Image.asset('assets/images/hoofbeat_icon.png', width: screenWidth * 0.08, height: screenWidth * 0.08), label: 'HoofBeat', onTap: () {}),
          _QuickActionButton(iconWidget: Image.asset('assets/images/flexes_icon.png', width: screenWidth * 0.08, height: screenWidth * 0.08), label: 'Flexes', onTap: () {}),
        ],
      ),
    );
  }

  Widget _buildEventsCarousel() {
    return PageView(
      controller: _pageController,
      onPageChanged: (index) {
        setState(() {
          _currentPageIndex = index;
        });
      },
      children: const [
        _HomecomingCard(),
        _HomecomingCard(),
        _HomecomingCard(),
      ],
    );
  }

  Widget _buildPageIndicator(double screenWidth) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        return Container(
          margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.01),
          width: screenWidth * 0.02,
          height: screenWidth * 0.02,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _currentPageIndex == index ? const Color(0xFF333333) : Colors.grey.withOpacity(0.4),
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
    final double screenWidth = MediaQuery.of(context).size.width;
    final double fontSize = screenWidth * 0.045;
    final double borderRadius = screenWidth * 0.04;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [iconWidget, SizedBox(width: screenWidth * 0.03), Text(label, style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.w600))],
        ),
      ),
    );
  }
}

class _HomecomingCard extends StatelessWidget {
  const _HomecomingCard();

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double cardRadius = screenWidth * 0.06;
    final double fontSizeTitle = screenWidth * 0.055;
    final double fontSizeSubtitle = screenWidth * 0.04;
    final double iconSize = screenWidth * 0.045;
    return Container(
      margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.06),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(cardRadius),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 3,
            child: Stack(
              fit: StackFit.expand,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(cardRadius), topRight: Radius.circular(cardRadius)),
                  child: Image.asset('assets/images/homecoming_bg.png', fit: BoxFit.contain),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.25),
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(cardRadius), topRight: Radius.circular(cardRadius)),
                  ),
                ),
                Center(
                  child: ShaderMask(
                    blendMode: BlendMode.srcIn,
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [Color(0xFFE474A2), Color(0xFF8A9AE4)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ).createShader(Rect.fromLTWH(0, 0, bounds.width, bounds.height)),
                    child: Text(
                      'HOMECOMING',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: screenWidth * 0.085,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Padding(
              padding: EdgeInsets.fromLTRB(screenWidth * 0.04, screenWidth * 0.04, screenWidth * 0.04, screenWidth * 0.03),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  RichText(
                    text: TextSpan(
                      style: TextStyle(fontSize: fontSizeTitle, fontWeight: FontWeight.w900, fontFamily: 'sans-serif'),
                      children: [
                        TextSpan(text: 'Homecoming ', style: TextStyle(color: Color(0xFFB94056))),
                        TextSpan(text: '2024', style: TextStyle(color: Color(0xFF2E4096))),
                      ],
                    ),
                  ),
                  SizedBox(height: screenWidth * 0.03),
                  Row(
                    children: [
                      Icon(Icons.calendar_today_outlined, size: iconSize, color: Colors.black),
                      SizedBox(width: screenWidth * 0.02),
                      Text('This Friday', style: TextStyle(fontSize: fontSizeSubtitle, color: Colors.black), maxLines: 1, overflow: TextOverflow.ellipsis),
                      const Spacer(),
                      Icon(Icons.more_horiz, size: iconSize * 1.2, color: Colors.black),
                      SizedBox(width: screenWidth * 0.01),
                      Text('More Details', style: TextStyle(fontSize: fontSizeSubtitle, color: Colors.black), maxLines: 1, overflow: TextOverflow.ellipsis),
                    ],
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
