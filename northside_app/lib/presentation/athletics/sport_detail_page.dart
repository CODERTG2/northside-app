// lib/presentation/athletics/sport_detail_page.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/utils/app_colors.dart'; // FIX: Corrected import path

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
  String _selectedLevel = 'All';
  final List<String> _levels = ['All', 'JV', 'Varsity'];

  final List<GameSchedule> _schedules = const [
    GameSchedule(date: '8/24', time: '11:30AM', event: 'Red North', opponent: 'Chicago (Lane)', location: 'CPS Hansen Field', score: '0-5', result: 'L'),
    GameSchedule(date: '8/24', time: '11:30AM', event: 'Red North', opponent: 'Chicago (Taft)', location: 'CPS Hansen Field', score: '3-1', result: 'W'),
    GameSchedule(date: '8/24', time: '11:30AM', event: 'Red North', opponent: 'Chicago (Whitney Young)', location: 'Northeastern Illinois', score: '0-5', result: 'L'),
  ];

  final List<Player> _roster = const [
    Player(name: 'John Appleseed', number: '10', position: 'Forward', grade: '12'),
    Player(name: 'Mac Pineapple', number: '7', position: 'Midfield', grade: '11'),
    Player(name: 'Peter Parker', number: '1', position: 'Goalkeeper', grade: '12'),
  ];

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
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: screenWidth * 0.07),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: screenWidth * 0.04),
            child: CircleAvatar(
              radius: screenWidth * 0.055,
              backgroundColor: Colors.grey.shade300,
              child: Icon(Icons.person, color: Colors.black, size: screenWidth * 0.07),
            ),
          ),
        ],
      ),
      body: ListView(
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
      ),
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
              onTap: () => setState(() => _selectedLevel = level),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: screenWidth * 0.02),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(screenWidth * 0.025),
                  boxShadow: isSelected ? [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 5, offset: const Offset(0, 2))] : [],
                ),
                child: Center(
                  child: Text(
                    level,
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
          Text(title, style: TextStyle(fontSize: screenWidth * 0.05, fontWeight: FontWeight.bold)),
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

  DataTable _buildRosterTable(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
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
    return Text(text, style: TextStyle(color: Colors.grey.shade500, fontWeight: FontWeight.w600, fontSize: screenWidth * 0.032));
  }

  Text _dataText(String text, double screenWidth) {
    return Text(text, style: TextStyle(fontWeight: FontWeight.w500, fontSize: screenWidth * 0.04), overflow: TextOverflow.ellipsis);
  }
}
