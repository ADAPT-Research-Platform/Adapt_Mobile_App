import 'dart:convert';

import 'package:adapt/services/session_manager.dart';

import '../utils/app_config.dart';

class SectionService {

  Future<String> fetchSectionContent(String sectionFolderPath) async {
    final String url = '${AppConfig.baseUrl}/app/uploads/$sectionFolderPath/content.md';

    try {
      final response = await SessionManager().client.get(
        Uri.parse(url),
        headers: SessionManager().getHeaders(),
      );

      if (response.statusCode == 200) {
        return utf8.decode(response.bodyBytes, allowMalformed: true);
      } else {
        print("Failed to load markdown content: ${response.statusCode}, ${response.body}");
        throw Exception("Failed to load markdown content");
      }
    } catch (e) {
      print("Error fetching markdown content: $e");
      return "";
    }
  }
}
