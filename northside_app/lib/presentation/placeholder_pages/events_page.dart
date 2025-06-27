// lib/presentation/placeholder_pages/events_page.dart

import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:get/get.dart';
import 'dart:collection';
import '../../models/article.dart';
import '../../widgets/article_detail_draggable_sheet.dart';
import '../../widgets/shared_header.dart';
import '../../core/utils/app_colors.dart'; // FIX: Corrected import path
import '../../core/theme/app_theme.dart';
import '../../core/utils/text_helper.dart';

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
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      body: ListView(
        padding: EdgeInsets.only(bottom: screenHeight * 0.12),
        children: [
          const SharedHeader(title: 'Events'),
          SizedBox(height: screenHeight * 0.02),
          _buildFilterButton(context),
          SizedBox(height: screenHeight * 0.02),
          _buildCalendar(context),
          SizedBox(height: screenHeight * 0.03),
          _buildEventList(context),
        ],
      ),
    );
  }

  Widget _buildFilterButton(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double fontSize = screenWidth * 0.045;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.06),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04, vertical: screenWidth * 0.02),
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            'For Current Year',
            style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.primaryBlue, fontSize: fontSize),
          ),
        ),
      ),
    );
  }

  Widget _buildCalendar(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isNarrowScreen = screenWidth < 360; // Check for S9 and similar small devices
    final double dayFontSize = isNarrowScreen ? screenWidth * 0.037 : screenWidth * 0.042;
    final double dowFontSize = isNarrowScreen ? screenWidth * 0.028 : screenWidth * 0.031;
    final double headerFontSize = isNarrowScreen ? screenWidth * 0.045 : screenWidth * 0.052;
    final double iconSize = isNarrowScreen ? screenWidth * 0.045 : screenWidth * 0.052;
    final double verticalPadding = isNarrowScreen ? screenWidth * 0.04 : screenWidth * 0.055;
    
    return Container(
      margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.06),
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04, vertical: verticalPadding),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      // Wrap in LayoutBuilder to adjust calendar based on available space
      child: LayoutBuilder(
        builder: (context, constraints) {
          return TableCalendar<Article>(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: _onDaySelected,
            eventLoader: _getEventsForDay,
            startingDayOfWeek: StartingDayOfWeek.sunday,
            // Adjust size to ensure it fits on small screens
            rowHeight: isNarrowScreen ? 40 : 50,
            headerStyle: HeaderStyle(
              formatButtonVisible: false,
              titleCentered: false,
              titleTextStyle: TextStyle(
                fontSize: headerFontSize,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              leftChevronIcon: Icon(Icons.arrow_back_ios, size: iconSize),
              rightChevronIcon: Icon(Icons.arrow_forward_ios, size: iconSize),
            ),
            daysOfWeekStyle: DaysOfWeekStyle(
              weekdayStyle: TextStyle(fontSize: dowFontSize, fontWeight: FontWeight.w600, color: Colors.grey.shade700),
              weekendStyle: TextStyle(fontSize: dowFontSize, fontWeight: FontWeight.w600, color: Colors.grey.shade700),
            ),
            calendarStyle: CalendarStyle(
              defaultTextStyle: TextStyle(fontSize: dayFontSize, color: Colors.black),
              weekendTextStyle: TextStyle(fontSize: dayFontSize, color: Colors.black),
              outsideTextStyle: TextStyle(fontSize: dayFontSize * 0.95, color: Colors.grey.shade400),
              todayDecoration: const BoxDecoration(color: AppColors.primaryBlue, shape: BoxShape.circle),
              selectedDecoration: const BoxDecoration(color: AppColors.primaryBlue, shape: BoxShape.circle),
            ),
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
            },
          );
        },
      ),
    );
  }

  Widget _buildEventList(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.06),
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
                  ArticleDetailDraggableSheet(article: article),
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  useRootNavigator: false,
                  enableDrag: true,
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
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isNarrowScreen = screenWidth < 360;
    return Container(
      padding: EdgeInsets.all(isNarrowScreen ? screenWidth * 0.04 : screenWidth * 0.05),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Center(
        child: TextHelper.responsiveText(
          'No Events Today',
          context: context,
          isBold: true,
          color: Colors.grey,
          customSizeMultiplier: isNarrowScreen ? 0.038 : 0.04,
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
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isNarrowScreen = screenWidth < 360;
    
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: isNarrowScreen ? screenWidth * 0.03 : screenWidth * 0.04),
      padding: EdgeInsets.all(isNarrowScreen ? screenWidth * 0.035 : screenWidth * 0.04),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextHelper.responsiveText(
            article.title,
            context: context,
            isBold: true,
            isTitle: true,
            maxLines: 2,
          ),
          SizedBox(height: isNarrowScreen ? screenWidth * 0.015 : screenWidth * 0.02),
          Row(
            children: [
              Icon(Icons.calendar_today_outlined, 
                  size: isNarrowScreen ? screenWidth * 0.04 : screenWidth * 0.045, 
                  color: Colors.grey.shade600),
              SizedBox(width: screenWidth * 0.02),
              Flexible(
                child: TextHelper.responsiveText(
                  article.subtitle,
                  context: context,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
