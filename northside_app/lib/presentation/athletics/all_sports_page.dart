// lib/presentation/athletics/all_sports_page.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/utils/app_colors.dart'; // FIX: Corrected import path
import '../../controllers/athletics_controller.dart';
import 'sport_detail_page.dart';

class SeasonSports {
  const SeasonSports({required this.mens, required this.womens});
  final List<String> mens;
  final List<String> womens;
}

class AllSportsPage extends StatefulWidget {
  const AllSportsPage({super.key});

  @override
  State<AllSportsPage> createState() => _AllSportsPageState();
}

class _AllSportsPageState extends State<AllSportsPage> {
  final AthleticsController athleticsController = Get.put(AthleticsController());
  String _selectedSeason = 'Fall';
  final List<String> _seasons = ['Fall', 'Winter', 'Spring'];

  // Get sports from backend data organized by season and gender
  SeasonSports _getSportsForSeason(String season) {
    final allSports = athleticsController.getAllAvailableSports();
    print('=== DEBUG: All available sports from backend (${allSports.length}): $allSports');
    
    // Get sports for this season from backend season data (completely backend-driven)
    final filteredSports = athleticsController.getSportsBySeason(season);
    print('=== DEBUG: Sports for $season from backend season data (${filteredSports.length}): $filteredSports');
    
    // Separate by gender based on backend data
    final mens = <String>[];
    final womens = <String>[];
    
    for (final sport in filteredSports) {
      // Check if this sport has male/boys athletes
      final maleAthletes = athleticsController.getAthletesBySport(
        sport: sport, 
        gender: 'boys'
      );
      if (maleAthletes.isNotEmpty) {
        mens.add(sport);
        print('=== DEBUG: Added $sport to mens (${maleAthletes.length} athletes)');
      }
      
      // Check if this sport has female/girls athletes  
      final femaleAthletes = athleticsController.getAthletesBySport(
        sport: sport,
        gender: 'girls'
      );
      if (femaleAthletes.isNotEmpty) {
        womens.add(sport);
        print('=== DEBUG: Added $sport to womens (${femaleAthletes.length} athletes)');
      }
    }
    
    print('=== DEBUG: Final result for $season - Mens: $mens, Womens: $womens');
    
    // Remove duplicates and sort
    return SeasonSports(
      mens: mens.toSet().toList()..sort(),
      womens: womens.toSet().toList()..sort(),
    );
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
      body: Obx(() {
        if (athleticsController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (athleticsController.error.value.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 48, color: Colors.red.shade300),
                SizedBox(height: 16),
                Text(
                  'Error loading sports data',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 8),
                Text(
                  athleticsController.error.value,
                  style: TextStyle(color: Colors.grey.shade600),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => athleticsController.refreshData(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }
        
        final currentSports = _getSportsForSeason(_selectedSeason);
        
        return ListView(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.06),
          children: [
            SizedBox(height: screenHeight * 0.02),
            _buildSeasonTabs(context),
            SizedBox(height: screenHeight * 0.03),
            _buildSportsColumns(context, currentSports),
          ],
        );
      }),
    );
  }

  Widget _buildSeasonTabs(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    return Container(
      padding: EdgeInsets.all(screenWidth * 0.01),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(screenWidth * 0.03),
      ),
      child: Row(
        children: _seasons.map((season) {
          final isSelected = _selectedSeason == season;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedSeason = season),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: screenWidth * 0.02),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(screenWidth * 0.025),
                  boxShadow: isSelected ? [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 5)] : [],
                ),
                child: Center(
                  child: Text(
                    season,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: isSelected ? AppColors.primaryBlue : Colors.grey.shade600,
                      fontSize: screenWidth * 0.045,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSportsColumns(BuildContext context, SeasonSports sports) {
    final double screenWidth = MediaQuery.of(context).size.width;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: _buildSportColumn(context, 'Men\'s', sports.mens)),
        SizedBox(width: screenWidth * 0.04),
        Expanded(child: _buildSportColumn(context, 'Women\'s', sports.womens)),
      ],
    );
  }

  Widget _buildSportColumn(BuildContext context, String title, List<String> sports) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final sportPrefix = title == 'Men\'s' ? 'Men\'s' : 'Women\'s';
    
    if (sports.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(bottom: screenWidth * 0.03),
            child: Text(
              title,
              style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600, fontSize: screenWidth * 0.045),
            ),
          ),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: screenWidth * 0.04),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(screenWidth * 0.04),
            ),
            child: Center(
              child: Text(
                'No sports available',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: screenWidth * 0.035,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ),
        ],
      );
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(bottom: screenWidth * 0.03),
          child: Text(
            title,
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600, fontSize: screenWidth * 0.045),
          ),
        ),
        ...sports.map((sport) {
          // Capitalize sport name for display
          final displayName = sport.split(' ').map((word) => 
            word.isNotEmpty ? word[0].toUpperCase() + word.substring(1).toLowerCase() : word
          ).join(' ');
          
          final fullSportName = sport.contains('Men\'s') || sport.contains('Women\'s') ? sport : '$sportPrefix $sport';
          return _SportChip(
            name: displayName,
            onTap: () => Get.to(() => SportDetailPage(sportName: fullSportName)),
          );
        }).toList(),
      ],
    );
  }
}

class _SportChip extends StatelessWidget {
  const _SportChip({required this.name, required this.onTap});
  final String name;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double fontSize = screenWidth * 0.04;
    final double borderRadius = screenWidth * 0.04;
    final double verticalPadding = screenWidth * 0.04;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        margin: EdgeInsets.only(bottom: screenWidth * 0.03),
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
          ),
        ),
      ),
    );
  }
}
