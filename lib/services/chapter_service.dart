import 'dart:convert';
import 'dart:io';

import 'package:adapt/services/session_manager.dart';
import 'package:logging/logging.dart';

import '../utils/app_config.dart';
import '../utils/app_keys.dart';
import '../widgets/snack_bar_shower.dart';

class ChapterService {
  final log = Logger('ChapterService');

  Future<String> fetchChapterContent(String filePath) async {
    try {
      final response = await SessionManager().client.get(
            Uri.parse(
                '${AppConfig.baseUrl}/uploads/$filePath'),
            headers: SessionManager().getHeaders(),
          );

      if (response.statusCode == 200) {
        return utf8.decode(response.bodyBytes, allowMalformed: true);
      } else {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        log.severe('Error in Get Chapter Content', jsonResponse['message']);
        throw HttpException(jsonResponse['message']);
      }
    } catch (e) {
      log.severe("Error in Get Chapter Content", e);
      rethrow;
    }
  }

  void addAnswer(String chapterId, Map<String, Map<String, String>> answers) async {
    try {
      final response = await SessionManager().client.post(
            Uri.parse('${AppConfig.baseUrl}/answers'),
            headers: SessionManager().getHeaders(),
            body: jsonEncode({
              'chapterId': chapterId,
              'text': answers,
            }),
          );

      log.info('Add/Update Answer Response: ${response.body}');
      if (response.statusCode == 200) {
        SnackBarShower.info(mainPageScaffold, 'Answer Updated Successfully!');
      } else if (response.statusCode == 201) {
        SnackBarShower.info(mainPageScaffold, 'Answer Added Successfully!');
      } else {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        SnackBarShower.error(mainPageScaffold, jsonResponse['message']);
      }
    } catch (e) {
      log.severe('Error in Answer Add/Update', e);
      SnackBarShower.error(mainPageScaffold, 'Internal App Error!');
    }
  }

  Future<Map<String, String>> fetchAnswer(String chapterId) async {
    // Add query parameters
    final Map<String, String> queryParams = {};
    queryParams['chapterId'] = chapterId;

    try {
      final response = await SessionManager().client.get(
            Uri.parse('${AppConfig.baseUrl}/answers')
                .replace(queryParameters: queryParams),
            headers: SessionManager().getHeaders(),
          );

      if (response.statusCode == 200) {
        // Decode the JSON response
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);

        // Extract the 'text' field and ensure it's a Map<String, dynamic>
        if (jsonResponse['text'] is Map<String, dynamic>) {
          final Map<String, dynamic> textMap = jsonResponse['text'];
          return textMap.map((key, value) {
            if (value is Map<String, dynamic> && value.containsKey('answer')) {
              // If value is a map and contains 'answer', extract the answer
              return MapEntry(key.toString(), value['answer'].toString());
            } else if (value is String) {
              // If value is a direct string, use it as the answer
              return MapEntry(key.toString(), value);
            } else {
              throw const HttpException('Invalid data format for answer!');
            }
          });
        } else {
          throw const HttpException('Invalid data format!');
        }
      } else if (response.statusCode == 404) {
        log.info("No Answers Found");
        return {};
      } else {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        log.severe(
            'Error in Get Answers By ChapterId', jsonResponse['message']);
        throw HttpException(jsonResponse['message']);
      }
    } catch (e) {
      log.severe('Error in Get Answers By ChapterId', e);
      rethrow;
    }
  }

  void updateProgress(String chapterId, double progress) async {
    try {
      final response = await SessionManager().client.post(
            Uri.parse('${AppConfig.baseUrl}/progress'),
            headers: SessionManager().getHeaders(),
            body: jsonEncode({
              'chapterId': chapterId,
              'progress': progress,
            }),
          );

      log.info('Update Progress Response: ${response.body}');
      if (response.statusCode == 200) {
        log.info(
            'Progress updated successfully! Chapter: $chapterId Progress: $progress');
      } else if (response.statusCode == 201) {
        log.info(
            'Progress added successfully! Chapter: $chapterId Progress: $progress');
      } else {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        SnackBarShower.error(mainPageScaffold, jsonResponse['message']);
      }
    } catch (e) {
      log.severe('Error in Update Progress: $e');
      SnackBarShower.error(mainPageScaffold, 'Internal App Error!');
    }
  }
}
