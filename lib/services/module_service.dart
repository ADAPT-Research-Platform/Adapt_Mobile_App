import 'dart:convert';

import 'package:adapt/services/session_manager.dart';

import '../models/module.dart';
import '../utils/app_config.dart';
import 'auth_service.dart';

class ModuleService {
  final AuthService _authService = AuthService();

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
        print("Failed to fetch module id list: ${response.statusCode}, ${response.body}");
        _authService.logout();
        throw Exception("Failed to fetch module id list");
      }
    } catch (e) {
      print("Error fetching module id list: $e");
      return [];
    }
  }

  Future<Module> fetchModuleById(String moduleId) async {
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
        print("Failed to fetch module: ${response.statusCode}, ${response.body}");
        _authService.logout();
        throw Exception("Failed to fetch module");
      }
    } catch (e) {
      print("Error fetching module: $e");
      rethrow;
    }
  }
}
