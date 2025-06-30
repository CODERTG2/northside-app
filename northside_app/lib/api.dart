import 'package:http/http.dart' as http;
import 'dart:convert';
import 'models/announcement.dart';
import 'models/athlete.dart';
import 'models/athletics_schedule.dart';
import 'models/general_event.dart';
import 'core/utils/logger.dart';

class ApiService {
  static const String baseUrl = "https://b8c7-2600-1700-67d0-50a0-00-46.ngrok-free.app/api";
  
  // Fetch announcements
  static Future<List<Announcement>> getAnnouncements({String? date}) async {
    try {
      String url = '/announcements';
      if (date != null) {
        url += '?date=$date';
      }
      
      final fullUrl = "$baseUrl$url";
      final response = await http.get(Uri.parse(fullUrl));
      
      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        return jsonList.map((json) => Announcement.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load announcements: ${response.statusCode}');
      }
    } catch (e) {
      AppLogger.error('Error fetching announcements', e);
      rethrow;
    }
  }

  // Fetch athletes/roster
  static Future<List<Athlete>> getRoster({
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
      
      final fullUrl = "$baseUrl$url";
      AppLogger.info('Making API request to: $fullUrl');
      
      final response = await http.get(Uri.parse(fullUrl));
      AppLogger.info('API Response status: ${response.statusCode}');
      AppLogger.debug('API Response body length: ${response.body.length}');
      
      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        AppLogger.info('Parsed ${jsonList.length} athletes from API');
        return jsonList.map((json) => Athlete.fromJson(json)).toList();
      } else {
        AppLogger.warning('API Error response body: ${response.body}');
        throw Exception('Failed to load roster: ${response.statusCode}');
      }
    } catch (e) {
      AppLogger.error('Error fetching roster', e);
      rethrow;
    }
  }

  // Fetch athletics schedule
  static Future<List<AthleticsSchedule>> getAthleticsSchedule({
    String? sport,
    String? gender,
    String? level,
    String? date,
    String? time,
    bool? home,
  }) async {
    try {
      String url = '/schedule/athletics';
      List<String> params = [];
      
      if (sport != null) params.add('sport=$sport');
      if (gender != null) params.add('gender=$gender');
      if (level != null) params.add('level=$level');
      if (date != null) params.add('date=$date');
      if (time != null) params.add('time=$time');
      if (home != null) params.add('home=$home');
      
      if (params.isNotEmpty) {
        url += '?${params.join('&')}';
      }
      
      final fullUrl = "$baseUrl$url";
      final response = await http.get(Uri.parse(fullUrl));
      
      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        return jsonList.map((json) => AthleticsSchedule.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load athletics schedule: ${response.statusCode}');
      }
    } catch (e) {
      AppLogger.error('Error fetching athletics schedule', e);
      rethrow;
    }
  }

  // Fetch general events
  static Future<List<GeneralEvent>> getGeneralEvents({
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
      
      final fullUrl = "$baseUrl$url";
      final response = await http.get(Uri.parse(fullUrl));
      
      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        return jsonList.map((json) => GeneralEvent.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load general events: ${response.statusCode}');
      }
    } catch (e) {
      AppLogger.error('Error fetching general events', e);
      rethrow;
    }
  }
}