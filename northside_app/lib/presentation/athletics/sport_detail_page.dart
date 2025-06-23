// lib/presentation/athletics/sport_detail_page.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';

// --- UPDATED Data Models ---
class GameSchedule {
  const GameSchedule({
    required this.date,
    required this.time,
    required this.event,
    required this.opponent,
    required this.location,
    required this.score,
    required this.result,
  });
  final String date;
  final String time;
  final String event;
  final String opponent;
  final String location;
  final String score;
  final String result;
}

class Player {
  const Player({
    required this.name,
    required this.number,
    required this.position,
    required this.grade,
  });
  final String name;
  final String number;
  final String position;
  final String grade;
}
// --- End of Data Models ---

class SportDetailPage extends StatefulWidget {
  const SportDetailPage({super.key, required this.sportName});
  final String sportName;

  @override
  State<SportDetailPage> createState() => _SportDetailPageState();
}

class _SportDetailPageState extends State<SportDetailPage> {
  // --- State and Placeholder Data ---
  final String _selectedLevel = 'All';
  final List<String> _levels = ['All', 'JV', 'Varsity'];

  final List<GameSchedule> _schedules = const [
    GameSchedule(date: '8/24', time: '11:30AM', event: 'Red North', opponent: 'Chicago (Lane)', location: 'CPS Hansen Field', score: '0-5', result: 'L'),
    GameSchedule(date: '8/24', time: '11:30AM', event: 'Red North', opponent: 'Chicago (Taft)', location: 'CPS Hansen Field', score: '3-1', result: 'W'),
    GameSchedule(date: '8/24', time: '11:30AM', event: 'Red North', opponent: 'Chicago (Whitney Young)', location: 'Northeastern Illinois', score: '0-5', result: 'L'),
    // ... add more placeholder data as needed
  ];

  final List<Player> _roster = const [
    Player(name: 'John Appleseed', number: '10', position: 'Forward', grade: '12'),
    Player(name: 'Mac Pineapple', number: '7', position: 'Midfield', grade: '11'),
    Player(name: 'Peter Parker', number: '1', position: 'Goalkeeper', grade: '12'),
    // ... add more placeholder data as needed
  ];
  // --- End of State ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.blue),
          onPressed: () => Get.back(),
        ),
        title: Text(
          widget.sportName,
          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 28),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              radius: 20,
              backgroundColor: Colors.grey.shade300,
              child: const Icon(Icons.person, color: Colors.black, size: 26),
            ),
          ),
        ],
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: _buildTeamLevelTabs(),
          ),
          const SizedBox(height: 24),
          _buildTableContainer('Schedules and Scores', _buildScheduleTable()),
          const SizedBox(height: 24),
          _buildTableContainer('Rosters', _buildRosterTable()),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  // --- Main UI Component Builder Methods ---

  Widget _buildTeamLevelTabs() {
    return Container( /* ... same as before ... */ );
  }

  Widget _buildTableContainer(String title, Widget table) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          // This makes the table scrollable horizontally
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: table,
          ),
        ],
      ),
    );
  }

  // --- Table Builder Methods ---

  Widget _buildScheduleTable() {
    return DataTable(
      columnSpacing: 30, // Adjust spacing between columns
      columns: ['DATE', 'TIME', 'EVENT', 'OPPONENT', 'LOCATION', 'SCORE', 'W/L'].map((h) => DataColumn(label: _headerText(h))).toList(),
      rows: _schedules.map((s) => DataRow(cells: [
        DataCell(_dataText(s.date)),
        DataCell(_dataText(s.time)),
        DataCell(_dataText(s.event)),
        DataCell(_dataText(s.opponent)),
        DataCell(_dataText(s.location)),
        DataCell(_dataText(s.score)),
        DataCell(_dataText(s.result)),
      ])).toList(),
    );
  }
  
  Widget _buildRosterTable() {
    return DataTable(
      columnSpacing: 30,
      columns: ['NAME', '#', 'POSITION', 'GRADE'].map((h) => DataColumn(label: _headerText(h))).toList(),
      rows: _roster.map((p) => DataRow(cells: [
        DataCell(_dataText(p.name)),
        DataCell(_dataText(p.number)),
        DataCell(_dataText(p.position)),
        DataCell(_dataText(p.grade)),
      ])).toList(),
    );
  }

  // --- Generic Helper Widgets ---

  Text _headerText(String text) {
    return Text(text, style: TextStyle(color: Colors.grey.shade500, fontWeight: FontWeight.w600, fontSize: 12));
  }

  Text _dataText(String text) {
    return Text(text, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14), overflow: TextOverflow.ellipsis);
  }
}
