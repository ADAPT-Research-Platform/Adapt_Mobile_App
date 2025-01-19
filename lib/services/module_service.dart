import 'dart:convert';
import 'dart:io';

import 'package:adapt/services/session_manager.dart';
import 'package:logging/logging.dart';

import '../models/module.dart';
import '../utils/app_config.dart';

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
        final Map<String, dynamic> data = jsonDecode(response.body);
        return Module.parse(data);
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
}
