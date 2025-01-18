import 'dart:convert';

import 'package:adapt/services/session_manager.dart';
import 'package:logging/logging.dart';

import '../enums/feeling.dart';
import '../models/mood.dart';
import '../utils/app_config.dart';

class MoodService {
  final log = Logger('MoodService');

  static const int maxMotivation = 10;

  void saveMode(Feeling feeling, int motivation) async {
    if(motivation < 0 || motivation > maxMotivation){
      log.info('Invalid motivation value');
      return;
    }

    try {
      final response = await SessionManager().client.post(
        Uri.parse('${AppConfig.baseUrl}/moods'),
        headers: SessionManager().getHeaders(),
        body: jsonEncode({
          'feeling': feeling.index,
          'motivation': motivation,
        }),
      );

      if (response.statusCode == 200) {
        log.info('Mood data updated successfully!');
      }else if (response.statusCode == 201) {
        log.info('Mood data added successfully!');
      } else if (response.statusCode == 400) {
        log.warning('Bad Request: ${response.body}');
      } else {
        log.severe('Mood data adding failed: ${response.statusCode}, ${response.body}');
      }
    } catch (e) {
      log.severe('Error during saving Mood data: $e');
    }
  }

  Future<List<Mood>> fetchModeList({DateTime? startDate, DateTime? endDate}) async {

    // Add query parameters
    final Map<String, String> queryParams = {};

    queryParams['startDate'] = (startDate != null) ? startDate.toIso8601String() : DateTime.now().toIso8601String();
    queryParams['endDate'] = (endDate != null) ? endDate.toIso8601String() : DateTime.now().toIso8601String();

    try {
      final response = await SessionManager().client.get(
        Uri.parse('${AppConfig.baseUrl}/moods').replace(queryParameters: queryParams),
        headers: SessionManager().getHeaders(),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        log.info("Mode Data Loaded");
        return data.map<Mood>((item) => Mood.parse(item)).toList();
      } else {
        log.severe('Failed to fetch mood list: ${response.statusCode}, ${response.body}');
        return [];
      }
    } catch (e) {
      log.severe('Error during fetching mood list: $e');
      return [];
    }
  }
}
