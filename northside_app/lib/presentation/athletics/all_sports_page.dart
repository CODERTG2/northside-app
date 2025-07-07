// lib/presentation/athletics/all_sports_page.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:figma_squircle/figma_squircle.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/utils/app_colors.dart';
import '../../controllers/athletics_controller.dart';
import '../../core/design_constants.dart';
import 'sport_detail_page.dart';

class AllSportsPage extends StatefulWidget {
  const AllSportsPage({super.key});

  @override
  State<AllSportsPage> createState() => _AllSportsPageState();
}

class _AllSportsPageState extends State<AllSportsPage> {
  final AthleticsController athleticsController = Get.put(AthleticsController());
  String _selectedGender = 'Girls';
  final List<String> _genders = ['Girls', 'Boys', 'Coed'];

  // Hardcoded sports list from the Northside Prep Athletics website
  // This ensures all sports are always available regardless of backend status
  static const Map<String, List<String>> _sportsByGender = {
    'Girls': [
      'Badminton',
      'Basketball', 
      'Bowling',
      'Cross Country',
      'Flag Football',
      'Golf',
      'Indoor Track',
      'Lacrosse',
      'Soccer',
      'Softball',
      'Swimming',
      'Tennis',
      'Track',
      'Volleyball',
      'Water Polo',
    ],
    'Boys': [
      'Baseball',
      'Basketball',
      'Bowling', 
      'Cross Country',
      'Golf',
      'Indoor Track',
      'Lacrosse',
      'Soccer',
      'Swimming',
      'Tennis',
      'Track',
      'Volleyball',
      'Water Polo',
      'Wrestling',
    ],
    'Coed': [
      'Competitive Cheer',
      'Dance',
      'Pom Pon',
    ],
  };

  List<String> _getSportsForGender(String gender) {
    return _sportsByGender[gender] ?? [];
  }
  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: AppColors.primaryBlue, size: screenWidth * 0.06),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'All Sports',
          style: GoogleFonts.inter(
            color: Colors.black, 
            fontWeight: FontWeight.w900, 
            fontSize: screenWidth * 0.07,
          ),
        ),
      ),
      body: ListView(
        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.06),
        children: [
          SizedBox(height: screenHeight * 0.02),
          _buildGenderTabs(context),
          SizedBox(height: screenHeight * 0.03),
          _buildSportsList(context),
        ],
      ),
    );
  }

  Widget _buildGenderTabs(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    return Container(
      padding: EdgeInsets.all(screenWidth * 0.01),
      decoration: ShapeDecoration(
        color: Colors.grey.shade200,          shape: SmoothRectangleBorder(
            borderRadius: SmoothBorderRadius(
              cornerRadius: DesignConstants.get32Radius(context),
              cornerSmoothing: 1.0,
            ),
          ),
      ),
      child: Row(
        children: _genders.map((gender) {
          final isSelected = _selectedGender == gender;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedGender = gender),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: screenWidth * 0.035),
                decoration: ShapeDecoration(
                  color: isSelected ? Colors.white : Colors.transparent,                    shape: SmoothRectangleBorder(
                      borderRadius: SmoothBorderRadius(
                        cornerRadius: DesignConstants.get28Radius(context),
                        cornerSmoothing: 1.0,
                      ),
                    ),
                  shadows: isSelected ? [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 2))] : null,
                ),
                child: Text(
                  gender,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: screenWidth * 0.04,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected ? AppColors.primaryBlue : Colors.grey.shade600,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSportsList(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final now = DateTime.now();
    final schedule = athleticsController.schedule;
    final isLoading = athleticsController.isLoading.value;
    // Show loading indicator if schedule is loading
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    // If schedule is empty, fallback to hardcoded list
    if (schedule.isEmpty) {
      final fallback = _getSportsForGender(_selectedGender);
      return GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: screenWidth * 0.04,
          mainAxisSpacing: screenWidth * 0.04,
          childAspectRatio: 2.5,
        ),
        itemCount: fallback.length,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          final sportName = fallback[index];
          return _SportCard(
            name: sportName,
            onTap: () => Get.to(() => SportDetailPage(
              sportName: sportName,
            )),
          );
        },
      );
    }
    // Get all upcoming games for the selected gender
    // Filter for future games and selected gender
    final upcoming = schedule.where((event) {
      // Parse event date
      DateTime? eventDate;
      try {
        if (event.date.contains('/')) {
          final parts = event.date.split('/');
          if (parts.length == 3) {
            final month = int.tryParse(parts[0]) ?? 1;
            final day = int.tryParse(parts[1]) ?? 1;
            final year = int.tryParse(parts[2]) ?? now.year;
            eventDate = DateTime(year, month, day);
          }
        } else if (event.date.contains(' ') && !event.date.contains('-')) {
          final parts = event.date.split(' ');
          if (parts.length == 3) {
            final monthMap = {
              'Jan': 1, 'Feb': 2, 'Mar': 3, 'Apr': 4, 'May': 5, 'Jun': 6,
              'Jul': 7, 'Aug': 8, 'Sep': 9, 'Oct': 10, 'Nov': 11, 'Dec': 12
            };
            final month = monthMap[parts[0]] ?? 1;
            final day = int.tryParse(parts[1]) ?? 1;
            final year = int.tryParse(parts[2]) ?? now.year;
            eventDate = DateTime(year, month, day);
          }
        } else {
          eventDate = DateTime.tryParse(event.date);
        }
      } catch (_) {}
      if (eventDate == null) return false;
      if (eventDate.isBefore(DateTime(now.year, now.month, now.day))) return false;
      // Gender filter
      if (_selectedGender == 'Coed') return true;
      return event.gender.toLowerCase() == _selectedGender.toLowerCase();
    }).toList();
    // Sort by date
    upcoming.sort((a, b) {
      DateTime aDate, bDate;
      try {
        aDate = DateTime.parse(a.date);
      } catch (_) {
        aDate = now.add(const Duration(days: 365));
      }
      try {
        bDate = DateTime.parse(b.date);
      } catch (_) {
        bDate = now.add(const Duration(days: 365));
      }
      return aDate.compareTo(bDate);
    });
    // Get unique sports by soonest game
    final seen = <String>{};
    final List<String> sports = [];
    for (final event in upcoming) {
      final sport = event.sport;
      if (!seen.contains(sport)) {
        seen.add(sport);
        sports.add(sport);
        if (sports.length == 4) break;
      }
    }
    // Fallback: if not enough, fill with hardcoded list
    if (sports.length < 4) {
      final fallback = _getSportsForGender(_selectedGender);
      for (final s in fallback) {
        if (!seen.contains(s)) {
          sports.add(s);
          if (sports.length == 4) break;
        }
      }
    }
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: screenWidth * 0.04,
        mainAxisSpacing: screenWidth * 0.04,
        childAspectRatio: 2.5,
      ),
      itemCount: sports.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        final sportName = sports[index];
        return _SportCard(
          name: sportName,
          onTap: () => Get.to(() => SportDetailPage(
            sportName: sportName,
          )),
        );
      },
    );
  }
}

class _SportCard extends StatelessWidget {
  const _SportCard({required this.name, required this.onTap});
  final String name;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double borderRadius = DesignConstants.get24Radius(context);
    final double verticalPadding = screenWidth * 0.04;
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: verticalPadding),
        decoration: ShapeDecoration(
          color: Colors.white,
          shape: SmoothRectangleBorder(
            borderRadius: SmoothBorderRadius(
              cornerRadius: borderRadius,
              cornerSmoothing: 1.0,
            ),
          ),
          shadows: DesignConstants.standardShadow,
        ),
        child: Center(
          child: Text(
            name,
            style: GoogleFonts.inter(fontSize: screenWidth * 0.045, fontWeight: FontWeight.bold),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
