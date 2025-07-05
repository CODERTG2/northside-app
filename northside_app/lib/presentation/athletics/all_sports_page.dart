// lib/presentation/athletics/all_sports_page.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:figma_squircle/figma_squircle.dart';
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
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: screenWidth * 0.07),
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
    final sports = _getSportsForGender(_selectedGender);
    
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
        // Create gender-prefixed sport name for proper filtering
        String genderPrefixedSportName = sportName;
        if (_selectedGender == 'Girls') {
          genderPrefixedSportName = "Girls $sportName";
        } else if (_selectedGender == 'Boys') {
          genderPrefixedSportName = "Boys $sportName";
        }
        // For Coed sports, pass without prefix to show all teams
        
        return _SportCard(
          name: sportName,
          onTap: () => Get.to(() => SportDetailPage(sportName: genderPrefixedSportName)),
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
    final double fontSize = screenWidth * 0.045;
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
            style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.w600),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
