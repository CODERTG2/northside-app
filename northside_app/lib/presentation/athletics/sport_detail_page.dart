// lib/presentation/athletics/sport_detail_page.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../controllers/athletics_controller.dart';
import '../../models/athlete.dart';
import '../../models/athletics_schedule.dart';
import '../../widgets/shared_header.dart';
import '../../core/utils/logger.dart';
import '../../core/utils/app_colors.dart';
import '../../api.dart';

class GameSchedule {
  const GameSchedule({required this.date, required this.time, required this.event, required this.opponent, required this.location, required this.score, required this.result});
  final String date;
  final String time;
  final String event;
  final String opponent;
  final String location;
  final String score;
  final String result;
}

class Player {
  const Player({required this.name, required this.number, required this.position, required this.grade});
  final String name;
  final String number;
  final String position;
  final String grade;
}

class SportDetailPage extends StatefulWidget {
  const SportDetailPage({super.key, required this.sportName});
  final String sportName;

  @override
  State<SportDetailPage> createState() => _SportDetailPageState();
}

class _SportDetailPageState extends State<SportDetailPage> {
  final AthleticsController athleticsController = Get.put(AthleticsController());
  String _selectedLevel = 'All';
  List<String> _levels = ['All'];
  List<GameSchedule> _schedules = [];
  List<Player> _roster = [];
  bool _isLoadingRoster = false;

  // Helper function to format level names for display
  String _formatLevelName(String level) {
    switch (level.toLowerCase()) {
      case 'varsity':
        return 'Varsity';
      case 'jv':
        return 'JV';
      case 'freshman':
        return 'Freshman';
      default:
        return level;
    }
  }

  // Helper function to sort levels in proper order
  List<String> _sortLevels(List<String> levels) {
    final levelOrder = ['varsity', 'jv', 'freshman'];
    final otherLevels = levels.where((level) => level.toLowerCase() != 'all' && !levelOrder.contains(level.toLowerCase())).toList();
    final orderedLevels = <String>[];
    
    for (String orderLevel in levelOrder) {
      for (String level in levels) {
        if (level.toLowerCase() == orderLevel) {
          orderedLevels.add(level);
          break;
        }
      }
    }
    
    orderedLevels.addAll(otherLevels);
    return ['All', ...orderedLevels];
  }

  @override
  void initState() {
    super.initState();
    _loadSportData();
  }

  void _loadSportData() async {
    // Extract sport name (remove gender prefix if present)
    String sportName = widget.sportName;
    String? gender;
    
    if (sportName.startsWith("Men's ")) {
      sportName = sportName.substring(6);
      gender = 'boys';
    } else if (sportName.startsWith("Women's ")) {
      sportName = sportName.substring(8);
      gender = 'girls';
    }

    // Convert sport name to lowercase for API compatibility
    sportName = sportName.toLowerCase();

    // Load all athletes for this sport/gender to get available levels
    try {
      final allAthletes = await ApiService.getRoster(
        sport: sportName,
        gender: gender,
      );
      final levels = allAthletes.map((athlete) => athlete.level).toSet().toList();
      _levels = _sortLevels(levels);
      AppLogger.debug('Available levels for $sportName ($gender): $_levels');
    } catch (e) {
      AppLogger.debug('Error loading levels: $e');
      // Fallback to controller data
      final allAthletes = athleticsController.getAthletesBySport(sport: sportName, gender: gender);
      final levels = allAthletes.map((athlete) => athlete.level).toSet().toList();
      _levels = _sortLevels(levels);
    }

    // Get schedule for this sport and gender
    final schedule = athleticsController.getScheduleByFilters(
      sport: sportName,
      gender: gender,
    );
    _schedules = schedule.map((event) => event.toGameSchedule()).toList();
    AppLogger.debug('Found ${_schedules.length} schedule items for sport: $sportName, gender: $gender');

    // Load initial roster
    _updateRoster();
    
    setState(() {});
  }

  void _updateRoster() async {
    String sportName = widget.sportName;
    String? gender;
    String? level;
    
    if (sportName.startsWith("Men's ")) {
      sportName = sportName.substring(6);
      gender = 'boys';
    } else if (sportName.startsWith("Women's ")) {
      sportName = sportName.substring(8);
      gender = 'girls';
    }

    // Convert sport name to lowercase for API compatibility
    sportName = sportName.toLowerCase();

    if (_selectedLevel != 'All') {
      level = _selectedLevel.toLowerCase();
    }

    AppLogger.debug('Updating roster with filters: sport=$sportName, gender=$gender, level=$level, selectedLevel=$_selectedLevel');

    setState(() {
      _isLoadingRoster = true;
    });

    // Load roster dynamically from API with filters
    try {
      final athletes = await ApiService.getRoster(
        sport: sportName,
        gender: gender,
        level: level,
      );
      _roster = athletes.map((athlete) => athlete.toPlayer()).toList();
      AppLogger.debug('Loaded ${_roster.length} athletes from API for sport: $sportName, gender: $gender, level: $level');
    } catch (e) {
      AppLogger.debug('Error loading filtered roster: $e');
      // Fallback to client-side filtering
      final athletes = athleticsController.getAthletesBySport(
        sport: sportName,
        gender: gender,
        level: level,
      );
      _roster = athletes.map((athlete) => athlete.toPlayer()).toList();
      AppLogger.debug('Loaded ${_roster.length} athletes from controller fallback for sport: $sportName, gender: $gender, level: $level');
    }

    if (mounted) {
      setState(() {
        _isLoadingRoster = false;
      });
    }
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
          widget.sportName,
          style: GoogleFonts.inter(
            color: Colors.black, 
            fontWeight: FontWeight.w900, 
            fontSize: screenWidth * 0.07,
          ),
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
                Text('Error: ${athleticsController.error.value}'),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => athleticsController.refreshData(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        return ListView(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.06),
              child: _buildTeamLevelTabs(context),
            ),
            SizedBox(height: screenHeight * 0.03),
            _buildTableContainer(context, 'Schedules and Scores', _buildScheduleTable(context)),
            SizedBox(height: screenHeight * 0.03),
            _buildTableContainer(context, 'Rosters', _buildRosterTable(context)),
            SizedBox(height: screenHeight * 0.05),
          ],
        );
      }),
    );
  }

  Widget _buildTeamLevelTabs(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    return Container(
      padding: EdgeInsets.all(screenWidth * 0.01),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(screenWidth * 0.03),
      ),
      child: Row(
        children: _levels.map((level) {
          final isSelected = _selectedLevel == level;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedLevel = level;
                  _updateRoster(); // Update roster when level changes
                });
              },
              child: Container(
                padding: EdgeInsets.symmetric(vertical: screenWidth * 0.02),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(screenWidth * 0.025),
                  boxShadow: isSelected ? [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 5, offset: const Offset(0, 2))] : [],
                ),
                child: Center(
                  child: Text(
                    _formatLevelName(level),
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: isSelected ? AppColors.primaryBlue : Colors.black,
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

  Widget _buildTableContainer(BuildContext context, String title, Widget table) {
    final double screenWidth = MediaQuery.of(context).size.width;
    return Container(
      margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.06),
      padding: EdgeInsets.all(screenWidth * 0.04),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(screenWidth * 0.04),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontSize: screenWidth * 0.05, fontWeight: FontWeight.w900)),
          SizedBox(height: screenWidth * 0.02),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: table,
          ),
        ],
      ),
    );
  }

  DataTable _buildScheduleTable(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    
    if (_schedules.isEmpty) {
      return DataTable(
        columnSpacing: screenWidth * 0.08,
        columns: ['DATE', 'TIME', 'EVENT', 'OPPONENT', 'LOCATION', 'SCORE', 'W/L'].map((h) => DataColumn(label: _headerText(h, screenWidth))).toList(),
        rows: [
          DataRow(cells: [
            DataCell(
              Container(
                width: screenWidth * 0.7, // Set explicit width
                padding: EdgeInsets.symmetric(vertical: screenWidth * 0.04),
                child: Center(
                  child: Text(
                    'No games currently scheduled',
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      color: Colors.grey[600],
                      fontSize: screenWidth * 0.035,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
            const DataCell(Text('')),
            const DataCell(Text('')),
            const DataCell(Text('')),
            const DataCell(Text('')),
            const DataCell(Text('')),
            const DataCell(Text('')),
          ]),
        ],
      );
    }
    
    return DataTable(
      columnSpacing: screenWidth * 0.08,
      columns: ['DATE', 'TIME', 'EVENT', 'OPPONENT', 'LOCATION', 'SCORE', 'W/L'].map((h) => DataColumn(label: _headerText(h, screenWidth))).toList(),
      rows: _schedules.map((s) => DataRow(cells: [
        DataCell(_dataText(s.date, screenWidth)),
        DataCell(_dataText(s.time, screenWidth)),
        DataCell(_dataText(s.event, screenWidth)),
        DataCell(_dataText(s.opponent, screenWidth)),
        DataCell(_dataText(s.location, screenWidth)),
        DataCell(_dataText(s.score, screenWidth)),
        DataCell(_dataText(s.result, screenWidth)),
      ])).toList(),
    );
  }

  Widget _buildRosterTable(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    
    if (_isLoadingRoster) {
      return Container(
        padding: EdgeInsets.all(screenWidth * 0.1),
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    if (_roster.isEmpty) {
      return DataTable(
        columnSpacing: screenWidth * 0.08,
        columns: ['NAME', '#', 'POSITION', 'GRADE'].map((h) => DataColumn(label: _headerText(h, screenWidth))).toList(),
        rows: [
          DataRow(cells: [
            DataCell(
              Container(
                width: screenWidth * 0.6, // Set explicit width
                padding: EdgeInsets.symmetric(vertical: screenWidth * 0.04),
                child: Center(
                  child: Text(
                    'No roster currently exists',
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      color: Colors.grey[600],
                      fontSize: screenWidth * 0.035,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
            const DataCell(Text('')),
            const DataCell(Text('')),
            const DataCell(Text('')),
          ]),
        ],
      );
    }
    
    return DataTable(
      columnSpacing: screenWidth * 0.08,
      columns: ['NAME', '#', 'POSITION', 'GRADE'].map((h) => DataColumn(label: _headerText(h, screenWidth))).toList(),
      rows: _roster.map((p) => DataRow(cells: [
        DataCell(_dataText(p.name, screenWidth)),
        DataCell(_dataText(p.number, screenWidth)),
        DataCell(_dataText(p.position, screenWidth)),
        DataCell(_dataText(p.grade, screenWidth)),
      ])).toList(),
    );
  }

  Text _headerText(String text, double screenWidth) {
    return Text(text, style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600, fontSize: screenWidth * 0.032));
  }

  Text _dataText(String text, double screenWidth) {
    return Text(text, style: TextStyle(fontWeight: FontWeight.w500, fontSize: screenWidth * 0.04), overflow: TextOverflow.ellipsis);
  }
}

// If there are any pop-up or modal info screens, wrap their content in SafeArea.
