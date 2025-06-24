// lib/presentation/athletics/all_sports_page.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/utils/app_colors.dart'; // FIX: Corrected import path
import 'sport_detail_page.dart';

class SeasonSports {
  const SeasonSports({required this.mens, required this.womens});
  final List<String> mens;
  final List<String> womens;
}

final Map<String, SeasonSports> _sportsData = {
  'Fall': const SeasonSports(
    mens: ['Cross Country', 'Golf', 'Softball 16in', 'Soccer'],
    womens: ['Cross Country', 'Golf', 'Cheer Leading', 'Dance', 'Tennis', 'Flag Football', 'Swimming', 'Volleyball'],
  ),
  'Winter': const SeasonSports(
    mens: ['Basketball', 'Bowling', 'Swimming', 'Wrestling'],
    womens: ['Basketball', 'Bowling', 'Indoor Track'],
  ),
  'Spring': const SeasonSports(
    mens: ['Baseball', 'Lacrosse', 'Tennis', 'Track & Field', 'Volleyball'],
    womens: ['Lacrosse', 'Soccer', 'Softball', 'Track & Field', 'Water Polo'],
  ),
};

class AllSportsPage extends StatefulWidget {
  const AllSportsPage({super.key});

  @override
  State<AllSportsPage> createState() => _AllSportsPageState();
}

class _AllSportsPageState extends State<AllSportsPage> {
  String _selectedSeason = 'Fall';
  final List<String> _seasons = ['Fall', 'Winter', 'Spring'];

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;
    final currentSports = _sportsData[_selectedSeason]!;

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
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: screenWidth * 0.07),
        ),
      ),
      body: ListView(
        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.06),
        children: [
          SizedBox(height: screenHeight * 0.02),
          _buildSeasonTabs(context),
          SizedBox(height: screenHeight * 0.03),
          _buildSportsColumns(context, currentSports),
        ],
      ),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(bottom: screenWidth * 0.03),
          child: Text(
            title,
            style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.w600, fontSize: screenWidth * 0.045),
          ),
        ),
        ...sports.map((sport) {
          final fullSportName = sport.contains('Men\'s') || sport.contains('Women\'s') ? sport : '$sportPrefix $sport';
          return _SportChip(
            name: sport,
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
