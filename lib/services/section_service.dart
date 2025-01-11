import 'dart:convert';

import 'package:adapt/services/session_manager.dart';

class SectionService {

  Future<String> fetchSectionContent(String url) async {
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
