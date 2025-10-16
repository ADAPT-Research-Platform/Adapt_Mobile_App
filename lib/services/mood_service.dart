import 'dart:convert';
import 'dart:io';

import 'package:adapt/services/notification_service.dart';
import 'package:adapt/services/session_manager.dart';
import 'package:logging/logging.dart';

import '../enums/feeling.dart';
import '../models/mood.dart';
import '../utils/app_config.dart';
import '../utils/app_keys.dart';
import '../widgets/snack_bar_shower.dart';

class MoodService {
  final log = Logger('MoodService');

  static const int maxMotivation = 10;

  void saveMode(Feeling feeling, int motivation) async {
    if(motivation < 0 || motivation > maxMotivation){
      log.warning('Invalid motivation value!');
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

      log.info('Add/Update Mood Response: ${response.body}');
      if (response.statusCode == 200) {
        SnackBarShower.info(mainPageScaffold, 'mood_update_success');
        NotificationService.updateMoodLastSubmitTime();
      }else if (response.statusCode == 201) {
        SnackBarShower.info(mainPageScaffold, 'mood_add_success');
        NotificationService.updateMoodLastSubmitTime();
      } else {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        SnackBarShower.error(mainPageScaffold, jsonResponse['message']);
      }
    } catch (e) {
      log.severe('Error in Mood Add/Update', e);
      SnackBarShower.error(mainPageScaffold, 'internal_app_error');
    }
  }

  Future<List<Mood>> fetchModeList({DateTime? startDate, DateTime? endDate}) async {
    log.shout('fetchModeList Called');

    // Validate that startDate is less than endDate
    if (startDate != null && endDate != null && startDate.isAfter(endDate)) {
      throw ArgumentError('Start date must be before or the same as the end date.');
    }

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
        return data.map<Mood>((item) => Mood.parse(item)).toList();
      } else {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        log.severe('Error in Get Mood Data By Date Range', jsonResponse['message']);
        throw HttpException(jsonResponse['message']);
      }
    } catch (e) {
      log.severe('Error in Get Mood Data By Date Range', e);
      rethrow;
    }
  }

  Future<bool> hasMoodBeenLoggedToday() async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

    try {
      final moods = await fetchModeList(startDate: startOfDay, endDate: endOfDay);
      return moods.isNotEmpty;
    } catch (e) {
      log.severe('Error checking if mood was logged today', e);
      return false;
    }
  }
}
