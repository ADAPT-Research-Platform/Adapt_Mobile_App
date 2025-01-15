import 'dart:convert';

import 'package:adapt/services/session_manager.dart';

import '../models/mood.dart';
import '../utils/app_config.dart';

class MoodService {

  void saveMode(int feeling, int motivation) async {
    const url = '${AppConfig.baseUrl}/api/mood';

    try {
      final response = await SessionManager().client.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'feeling': feeling,
          'motivation': motivation,
        }),
      );

      if (response.statusCode == 200) {
        print('Mood data updated successfully!');
      }else if (response.statusCode == 201) {
        print('Mood data added successfully!');
      } else if (response.statusCode == 400) {
        print('Bad Request: ${response.body}');
      } else {
        print('Mood data adding failed: ${response.statusCode}, ${response.body}');
      }
    } catch (e) {
      print('Error during saving Mood data: $e');
    }
  }

  Future<List<Mood>> fetchModeList({DateTime? startDate, DateTime? endDate}) async {

    // Add query parameters
    final Map<String, String> queryParams = {};

    queryParams['startDate'] = (startDate != null) ? startDate.toIso8601String() : DateTime.now().toIso8601String();
    queryParams['endDate'] = (endDate != null) ? endDate.toIso8601String() : DateTime.now().toIso8601String();

    try {
      final response = await SessionManager().client.get(
        Uri.parse('${AppConfig.baseUrl}/api/mood').replace(queryParameters: queryParams),
        headers: SessionManager().getHeaders(),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map<Mood>((item) => parseMode(item)).toList();
      } else {
        print('Failed to fetch mood list: ${response.statusCode}, ${response.body}');
        return [];
      }
    } catch (e) {
      print('Error during fetching mood list: $e');
      return [];
    }
  }

  Mood parseMode(String data) {
    // Split the string using the '|' delimiter
    final parts = data.split('|');

    // Parse the components
    final timeStamp = DateTime.parse(parts[0]); // Parse the timestamp
    final feeling = int.parse(parts[1]); // Parse the feeling
    final motivation = int.parse(parts[2]); // Parse the motivation

    return Mood(
      timeStamp: timeStamp,
      feeling: feeling,
      motivation: motivation,
    );
  }
}
