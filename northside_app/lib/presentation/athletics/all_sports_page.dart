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
    final currentSports = _sportsData[_selectedSeason]!;

    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.primaryBlue),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'All Sports',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              radius: 18,
              backgroundColor: Colors.grey.shade300,
              child: const Icon(Icons.person, color: Colors.black, size: 24),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        children: [
          const SizedBox(height: 16),
          _buildSeasonTabs(),
          const SizedBox(height: 24),
          _buildSportsColumns(currentSports),
        ],
      ),
    );
  }

  Widget _buildSeasonTabs() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: _seasons.map((season) {
          final isSelected = _selectedSeason == season;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedSeason = season),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: isSelected ? [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 5)] : [],
                ),
                child: Center(
                  child: Text(
                    season,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: isSelected ? AppColors.primaryBlue : Colors.grey.shade600,
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

  Widget _buildSportsColumns(SeasonSports sports) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: _buildSportColumn('Men\'s', sports.mens)),
        const SizedBox(width: 16),
        Expanded(child: _buildSportColumn('Women\'s', sports.womens)),
      ],
    );
  }

  Widget _buildSportColumn(String title, List<String> sports) {
    final sportPrefix = title == 'Men\'s' ? 'Men\'s' : 'Women\'s';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: Text(
            title,
            style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.w600),
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Center(
          child: Text(
            name,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }
}
