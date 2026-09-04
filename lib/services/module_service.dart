import 'dart:convert';
import 'dart:io';

import 'package:adapt/enums/language.dart';
import 'package:adapt/services/session_manager.dart';
import 'package:logging/logging.dart';

import '../models/module.dart';
import '../utils/app_config.dart';
import 'localization_service.dart';

class ModuleService {
  final log = Logger('ModuleService');

  Future<List<String>> fetchModuleIdList() async {
    try {
      final response = await SessionManager().client.get(
        Uri.parse('${AppConfig.baseUrl}/modules/ids'),
        headers: SessionManager().getHeaders(),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map<String>((item) => item).toList();
      } else {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        log.severe('Error in Get Module Id List', jsonResponse['message']);
        throw HttpException(jsonResponse['message']);
      }
    } catch (e) {
      log.severe('Error in Get Module Id List', e);
      rethrow;
    }
  }

  Future<Module> fetchModuleById(String moduleId) async {
    if(moduleId.isEmpty){
      throw Exception('Invalid Module Id');
    }

    // Add query parameters
    final Map<String, String> queryParams = {};
    queryParams['moduleId'] = moduleId;

    try {
      final response = await SessionManager().client.get(
        Uri.parse('${AppConfig.baseUrl}/modules').replace(queryParameters: queryParams),
        headers: SessionManager().getHeaders(),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> modulesData = jsonDecode(response.body);
        final Map<String, dynamic> titlesData = await fetchChapterTitles(moduleId);

        return Module.parse(modulesData, titlesData);
      } else {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        log.severe('Error in Get Module By Id', jsonResponse['message']);
        throw HttpException(jsonResponse['message']);
      }
    } catch (e) {
      log.severe('Error in Get Module By Id', e);
      rethrow;
    }
  }

  Future<List<String>> fetchDiaryDateList() async {
    try {
      final response = await SessionManager().client.get(
        Uri.parse('${AppConfig.baseUrl}/modules/diaryDates'),
        headers: SessionManager().getHeaders(),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map<String>((item) => item).toList();
      } else {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        log.severe('Error in Get Diary Date List', jsonResponse['message']);
        throw HttpException(jsonResponse['message']);
      }
    } catch (e) {
      log.severe('Error in Get Diary Date List', e);
      rethrow;
    }
  }

  Future<Map<String, dynamic>> fetchChapterTitles(String moduleId) async {
    try {
      final response = await SessionManager().client.get(
        Uri.parse('${AppConfig.contentUrl}/module_0$moduleId/titles_${LocalizationService().getSelectedLanguage().code}.json'),
        headers: {
          'Authorization': 'Bearer ${AppConfig.contentAccessToken}',
          'Accept': 'application/vnd.github.v3.raw', // Get raw file content
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        log.severe('Error response in Get Chapter Titles', jsonResponse['message']);
        //throw HttpException(jsonResponse['message']);
        return {};
      }
    } catch (e) {
      log.severe("Error in Get Chapter Titles", e);
      rethrow;
    }
  }
}
