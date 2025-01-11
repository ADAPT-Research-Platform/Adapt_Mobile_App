import 'dart:convert';

import 'package:adapt/services/session_manager.dart';

import '../models/mode.dart';
import '../utils/app_config.dart';

class ModeService {

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

  Future<List<Mode>> fetchModeList() async {
    const url = '${AppConfig.baseUrl}/api/users/mood';

    try {
      final response = await SessionManager().client.get(
        Uri.parse(url),
        headers: SessionManager().getHeaders(),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map<Mode>((item) => parseMode(item)).toList();
      } else {
        print('Failed to fetch mood list: ${response.statusCode}, ${response.body}');
        return [];
      }
    } catch (e) {
      print('Error during fetching mood list: $e');
      return [];
    }
  }

  Mode parseMode(Map<String, dynamic> json) {
    return Mode(
      modeId: json['id'].toString(),
      timeStamp: DateTime.parse(json['createdAt']),
      feeling: json['feeling'],
      motivation: json['motivation'],
    );
  }
}
