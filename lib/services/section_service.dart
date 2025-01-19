import 'dart:convert';
import 'dart:io';

import 'package:adapt/services/session_manager.dart';
import 'package:logging/logging.dart';

import '../utils/app_config.dart';
import '../utils/app_keys.dart';
import '../widgets/snack_bar_shower.dart';

class SectionService {
  final log = Logger('SectionService');

  Future<String> fetchSectionContent(String sectionFolderPath) async {
    try {
      final response = await SessionManager().client.get(
        Uri.parse('${AppConfig.baseUrl}/uploads/$sectionFolderPath/content.md'),
        headers: SessionManager().getHeaders(),
      );

      if (response.statusCode == 200) {
        return utf8.decode(response.bodyBytes, allowMalformed: true);
      } else {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        log.severe('Error in Get Section Content', jsonResponse['message']);
        throw HttpException(jsonResponse['message']);
      }
    } catch (e) {
      log.severe("Error in Get Section Content", e);
      rethrow;
    }
  }

  void addAnswer(String sectionId, Map<String, String> answers) async {
    try {
      final response = await SessionManager().client.post(
        Uri.parse('${AppConfig.baseUrl}/answers'),
        headers: SessionManager().getHeaders(),
        body: jsonEncode({
          'sectionId': sectionId,
          'text': answers,
        }),
      );

      log.info('Add/Update Answer Response: ${response.body}');
      if (response.statusCode == 200) {
        SnackBarShower.info(mainPageScaffold, 'Answer Updated Successfully!');
      }else if (response.statusCode == 201) {
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

  Future<Map<String, String>> fetchAnswer(String sectionId) async {
    // Add query parameters
    final Map<String, String> queryParams = {};
    queryParams['sectionId'] = sectionId;

    try {
      final response = await SessionManager().client.get(
        Uri.parse('${AppConfig.baseUrl}/answers').replace(queryParameters: queryParams),
        headers: SessionManager().getHeaders(),
      );

      if (response.statusCode == 200) {
        // Decode the JSON response
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);

        // Extract the 'text' field and ensure it's a Map<String, String>
        if (jsonResponse['text'] is Map<String, dynamic>) {
          final Map<String, dynamic> textMap = jsonResponse['text'];
          return textMap.map((key, value) => MapEntry(key.toString(), value.toString()));
        } else {
          throw const HttpException('Invalid data format!');
        }
      }else if (response.statusCode == 404) {
        log.info("No Answers Found");
        return {};
      } else {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        log.severe('Error in Get Answers By SectionId', jsonResponse['message']);
        throw HttpException(jsonResponse['message']);
      }
    } catch (e) {
      log.severe('Error in Get Answers By SectionId', e);
      rethrow;
    }
  }

  void updateProgress(String sectionId, double progress) async {
    try {
      final response = await SessionManager().client.post(
        Uri.parse('${AppConfig.baseUrl}/progress'),
        headers: SessionManager().getHeaders(),
        body: jsonEncode({
          'sectionId': sectionId,
          'progress': progress,
        }),
      );

      log.info('Update Progress Response: ${response.body}');
      if (response.statusCode == 200) {
        log.info('Progress updated successfully! Section: $sectionId Progress: $progress');
      }else if (response.statusCode == 201) {
        log.info('Progress added successfully! Section: $sectionId Progress: $progress');
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
