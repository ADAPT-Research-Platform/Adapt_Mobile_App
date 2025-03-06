import 'dart:convert';
import 'dart:io';

import 'package:adapt/models/answer.dart';
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
            Uri.parse('${AppConfig.baseUrl}/uploads/$filePath'),
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

  void addAnswer(String chapterId, Map<String, String> answers) async {
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

  Future<Answer?> fetchAnswerByChapterId(String chapterId) async {
    // Add query parameters
    final Map<String, String> queryParams = {};
    queryParams['chapterId'] = chapterId;

    try {
      final response = await SessionManager().client.get(
            Uri.parse('${AppConfig.baseUrl}/answers/getByChapterId').replace(queryParameters: queryParams),
            headers: SessionManager().getHeaders(),
          );

      if (response.statusCode == 200) {
        // Decode the JSON response
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);

        // Extract the 'text' field and ensure it's a Map<String, String>
        if (jsonResponse['text'] is Map<String, dynamic>) {
          final Map<String, dynamic> data = jsonDecode(response.body);
          return Answer.parse(data);
        } else {
          throw const HttpException('Invalid data format!');
        }
      } else if (response.statusCode == 404) {
        log.info("No Answers Found");
        return null;
      } else {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        log.severe('Error in Get Answers By ChapterId', jsonResponse['message']);
        throw HttpException(jsonResponse['message']);
      }
    } catch (e) {
      log.severe('Error in Get Answers By ChapterId', e);
      rethrow;
    }
  }

  Future<List<Answer>> fetchAnswerByDate(DateTime date) async {
    // Add query parameters
    final Map<String, String> queryParams = {};
    queryParams['date'] = date.toIso8601String(); // Format as YYYY-MM-DD

    try {
      final response = await SessionManager().client.get(
        Uri.parse('${AppConfig.baseUrl}/answers/getByDate').replace(queryParameters: queryParams),
        headers: SessionManager().getHeaders(),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Answer.parse(json)).toList();
      } else if (response.statusCode == 404) {
        log.info("No Answers Found");
        return [];
      } else {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        log.severe('Error in Get Answers By Date', jsonResponse['message']);
        throw HttpException(jsonResponse['message']);
      }
    } catch (e, stacktrace) {
      log.severe('Error in Get Answers By Date', e, stacktrace);
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
        log.info('Progress updated successfully! Chapter: $chapterId Progress: $progress');
      } else if (response.statusCode == 201) {
        log.info('Progress added successfully! Chapter: $chapterId Progress: $progress');
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
