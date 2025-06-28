import 'package:http/http.dart' as http;
import 'dart:convert';
import 'models/announcement.dart';
import 'models/athlete.dart';
import 'models/athletics_schedule.dart';
import 'models/general_event.dart';

class ApiService {
  static const String baseUrl = "https://b8c7-2600-1700-67d0-50a0-00-46.ngrok-free.app/api";
  
  // Instance methods for controller compatibility
  Future<List<Announcement>> getAnnouncements({String? date}) async {
    try {
      return await fetchAnnouncements(date: date);
    } catch (e) {
      print('API call failed, using fallback data: $e');
      // Return fallback data that matches the real backend format
      return [
        Announcement(
          id: '6860296832409b23e0fa2150',
          date: '6/13/2025',
          title: 'Summer!',
          description: 'Summer!',
          createdBy: 'NCP Admin',
          createdAt: DateTime.fromMillisecondsSinceEpoch(1751114520305),
        ),
        Announcement(
          id: '2',
          date: '6/29/2025',
          title: 'Upcoming Fall Semester',
          description: 'Get ready for an exciting fall semester! Registration opens soon.',
          createdBy: 'Academic Office',
          createdAt: DateTime(2025, 6, 29),
        ),
        Announcement(
          id: '3',
          date: '7/1/2025',
          title: 'Summer Sports Camp',
          description: 'Join us for our annual summer sports camp starting July 1st.',
          createdBy: 'Athletics',
          createdAt: DateTime(2025, 7, 1),
        ),
      ];
    }
  }
  
  Future<List<Athlete>> getRoster({
    String? sport,
    String? gender,
    String? level,
  }) async {
    try {
      return await fetchRoster(sport: sport, gender: gender, level: level);
    } catch (e) {
      // Return fallback data when API fails
      return [];
    }
  }
  
  Future<List<AthleticsSchedule>> getAthleticsSchedule({
    String? sport,
    String? team,
    String? date,
    String? time,
    bool? home,
  }) async {
    try {
      return await fetchAthleticsSchedule(sport: sport, team: team, date: date, time: time, home: home);
    } catch (e) {
      // Return fallback data when API fails
      return [];
    }
  }
  
  Future<List<GeneralEvent>> getGeneralEvents({
    String? date,
    String? time,
    String? name,
  }) async {
    try {
      return await fetchGeneralEvents(date: date, time: time, name: name);
    } catch (e) {
      // Return fallback data when API fails
      return [
        GeneralEvent(
          id: '1',
          name: 'Welcome Back Assembly',
          date: '6/30/2025',
          time: '9:00 AM',
          location: 'Main Auditorium',
          description: 'Welcome back students for the new semester!',
          createdBy: 'Admin',
          createdAt: DateTime(2025, 6, 30),
        ),
        GeneralEvent(
          id: '2',
          name: 'Summer Festival',
          date: '7/4/2025',
          time: '6:00 PM',
          location: 'School Grounds',
          description: 'Join us for our annual summer festival celebration.',
          createdBy: 'Events Team',
          createdAt: DateTime(2025, 7, 4),
        ),
      ];
    }
  }
  
  // Generic method to fetch data from any endpoint
  static Future<String> fetchData(String url) async {
    try {
      final fullUrl = "$baseUrl$url";
      final response = await http.get(Uri.parse(fullUrl));
      
      if (response.statusCode == 200) {
        return response.body;
      } else {
        throw Exception('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Fetch announcements
  static Future<List<Announcement>> fetchAnnouncements({String? date}) async {
    try {
      String url = '/announcements';
      if (date != null) {
        url += '?date=$date';
      }
      
      final responseBody = await fetchData(url);
      final List<dynamic> jsonList = json.decode(responseBody);
      return jsonList.map((json) => Announcement.fromJson(json)).toList();
    } catch (e) {
      print('Error fetching announcements: $e');
      return [];
    }
  }

  // Fetch athletes/roster
  static Future<List<Athlete>> fetchRoster({
    String? sport,
    String? gender,
    String? level,
  }) async {
    try {
      String url = '/roster';
      List<String> params = [];
      
      if (sport != null) params.add('sport=$sport');
      if (gender != null) params.add('gender=$gender');
      if (level != null) params.add('level=$level');
      
      if (params.isNotEmpty) {
        url += '?${params.join('&')}';
      }
      
      final responseBody = await fetchData(url);
      final List<dynamic> jsonList = json.decode(responseBody);
      return jsonList.map((json) => Athlete.fromJson(json)).toList();
    } catch (e) {
      print('Error fetching roster: $e');
      return [];
    }
  }

  // Fetch athletics schedule
  static Future<List<AthleticsSchedule>> fetchAthleticsSchedule({
    String? sport,
    String? team,
    String? date,
    String? time,
    bool? home,
  }) async {
    try {
      String url = '/schedule/athletics';
      List<String> params = [];
      
      if (sport != null) params.add('sport=$sport');
      if (team != null) params.add('team=$team');
      if (date != null) params.add('date=$date');
      if (time != null) params.add('time=$time');
      if (home != null) params.add('home=$home');
      
      if (params.isNotEmpty) {
        url += '?${params.join('&')}';
      }
      
      final responseBody = await fetchData(url);
      final List<dynamic> jsonList = json.decode(responseBody);
      return jsonList.map((json) => AthleticsSchedule.fromJson(json)).toList();
    } catch (e) {
      print('Error fetching athletics schedule: $e');
      return [];
    }
  }

  // Fetch general events
  static Future<List<GeneralEvent>> fetchGeneralEvents({
    String? date,
    String? time,
    String? name,
  }) async {
    try {
      String url = '/schedule/general';
      List<String> params = [];
      
      if (date != null) params.add('date=$date');
      if (time != null) params.add('time=$time');
      if (name != null) params.add('name=$name');
      
      if (params.isNotEmpty) {
        url += '?${params.join('&')}';
      }
      
      final responseBody = await fetchData(url);
      final List<dynamic> jsonList = json.decode(responseBody);
      return jsonList.map((json) => GeneralEvent.fromJson(json)).toList();
    } catch (e) {
      print('Error fetching general events: $e');
      return [];
    }
  }
}

// Legacy function for backward compatibility
Future<String> fetchdata(String url) async {
  return ApiService.fetchData(url);
}