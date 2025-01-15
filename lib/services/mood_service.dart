import 'dart:convert';

import 'package:adapt/services/session_manager.dart';

import '../models/mood.dart';
import '../utils/app_config.dart';

class MoodService {

  void saveMode(int feeling, int motivation) async {
    const url = '${AppConfig.baseUrl}/api/users/mood';

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

      if (response.statusCode == 201) {
        print('Mood saved successfully.');
      } else {
        print('Failed to save mood: ${response.statusCode}, ${response.body}');
      }
    } catch (e) {
      print('Error during saving mood: $e');
    }
  }

  Future<List<Mood>> fetchModeList({DateTime? startDate, DateTime? endDate}) async {

    // Add query parameters
    final Map<String, String> queryParams = {};

    queryParams['startDate'] = (startDate != null) ? startDate.toIso8601String() : DateTime.now().toIso8601String();
    queryParams['endDate'] = (endDate != null) ? endDate.toIso8601String() : DateTime.now().toIso8601String();

    try {
      final response = await SessionManager().client.get(
        Uri.parse('${AppConfig.baseUrl}/api/users/mood').replace(queryParameters: queryParams),
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
