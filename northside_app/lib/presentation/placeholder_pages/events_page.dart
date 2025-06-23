// lib/presentation/placeholder_pages/events_page.dart

import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:get/get.dart';
import 'dart:collection';
import '../../models/article.dart';
import '../../widgets/article_detail_sheet.dart';
import '../../widgets/shared_header.dart';
import '../../core/utils/app_colors.dart';

// FIX: Article objects now correctly omit the date
final kEvents = LinkedHashMap<DateTime, List<Article>>(
  equals: isSameDay,
  hashCode: (key) => key.day * 1000000 + key.month * 10000 + key.year,
)..addAll({
  DateTime.now().subtract(const Duration(days: 2)): [const Article(title: 'Team Meeting', subtitle: '3:00 PM - Room 101', content: 'Planning session for the upcoming season.')],
  DateTime.now(): [
    const Article(title: 'Parent-Teacher Conference', subtitle: 'All Day', content: 'Scheduled conferences to discuss student progress.'),
    const Article(title: 'Soccer Game @ 7PM', subtitle: 'Varsity Field', content: 'Our team takes on the Taft Eagles. Come out and support!')
  ],
  DateTime.now().add(const Duration(days: 5)): [const Article(title: 'School Play Auditions', subtitle: 'Auditorium', content: 'Auditions for the spring production of "Hamlet" will be held after school.')],
});

class EventsPage extends StatefulWidget {
  const EventsPage({super.key});

  @override
  State<EventsPage> createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage> {
  late final ValueNotifier<List<Article>> _selectedEvents;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _selectedEvents = ValueNotifier(_getEventsForDay(_selectedDay!));
  }

  @override
  void dispose() {
    _selectedEvents.dispose();
    super.dispose();
  }

  List<Article> _getEventsForDay(DateTime day) {
    return kEvents[day] ?? [];
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
      });
      _selectedEvents.value = _getEventsForDay(selectedDay);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 120),
        children: [
          const SharedHeader(title: 'Events'),
          const SizedBox(height: 16),
          _buildFilterButton(),
          const SizedBox(height: 16),
          _buildCalendar(),
          const SizedBox(height: 24),
          _buildEventList(),
        ],
      ),
    );
  }
  
  Widget _buildFilterButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Text(
            'For Current Year',
            style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.primaryBlue),
          ),
        ),
      ),
    );
  }
  
  Widget _buildCalendar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: TableCalendar<Article>(
        firstDay: DateTime.utc(2020, 1, 1),
        lastDay: DateTime.utc(2030, 12, 31),
        focusedDay: _focusedDay,
        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
        onDaySelected: _onDaySelected,
        eventLoader: _getEventsForDay,
        startingDayOfWeek: StartingDayOfWeek.sunday,
        headerStyle: const HeaderStyle(
          formatButtonVisible: false,
          titleCentered: false,
          titleTextStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          leftChevronIcon: Icon(Icons.arrow_back_ios, size: 16),
          rightChevronIcon: Icon(Icons.arrow_forward_ios, size: 16),
        ),
        calendarStyle: const CalendarStyle(
          todayDecoration: BoxDecoration(color: AppColors.primaryBlue, shape: BoxShape.circle),
          selectedDecoration: BoxDecoration(color: AppColors.primaryBlue, shape: BoxShape.circle),
        ),
        onPageChanged: (focusedDay) {
          _focusedDay = focusedDay;
        },
      ),
    );
  }

  Widget _buildEventList() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: ValueListenableBuilder<List<Article>>(
        valueListenable: _selectedEvents,
        builder: (context, value, _) {
          if (value.isEmpty) {
            return const _NoEventsCard();
          }
          return Column(
            children: value.map((article) => GestureDetector(
              onTap: () {
                Get.bottomSheet(
                  ArticleDetailSheet(article: article),
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                );
              },
              child: _EventDetailCard(article: article),
            )).toList(),
          );
        },
      ),
    );
  }
}

class _NoEventsCard extends StatelessWidget {
  const _NoEventsCard();
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: const Center(
        child: Text(
          'No Events Today',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey),
        ),
      ),
    );
  }
}

class _EventDetailCard extends StatelessWidget {
  const _EventDetailCard({required this.article});
  final Article article;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(article.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.calendar_today_outlined, size: 16, color: Colors.grey.shade600),
              const SizedBox(width: 8),
              Text(article.subtitle, style: TextStyle(fontSize: 14, color: Colors.grey.shade700)),
            ],
          ),
        ],
      ),
    );
  }
}
