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

  void addAnswer(String sectionId, Map<String, String> answers) async {
    try {
      final response = await SessionManager().client.post(
        Uri.parse('${AppConfig.baseUrl}/api/answers'),
        headers: SessionManager().getHeaders(),
        body: jsonEncode({
          'sectionId': sectionId,
          'text': answers,
        }),
      );

      if (response.statusCode == 200) {
        print('Answer updated successfully!');
      }else if (response.statusCode == 201) {
        print('Answer added successfully!');
      } else if (response.statusCode == 400) {
        print('Bad Request: ${response.body}');
      } else {
        print('Answer adding failed: ${response.statusCode}, ${response.body}');
      }
    } catch (e) {
      print('Error during answering: $e');
    }
  }

  Future<Map<String, String>> fetchAnswer(String sectionId) async {
    // Add query parameters
    final Map<String, String> queryParams = {};
    queryParams['sectionId'] = sectionId;

    try {
      final response = await SessionManager().client.get(
        Uri.parse('${AppConfig.baseUrl}/api/answers').replace(queryParameters: queryParams),
        headers: SessionManager().getHeaders(),
      );

      if (response.statusCode == 200) {
        // Decode the JSON response
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);

        // Extract the 'text' field and ensure it's a Map<String, String>
        if (jsonResponse['text'] is Map<String, dynamic>) {
          final Map<String, dynamic> textMap = jsonResponse['text'];
          return textMap.map((key, value) =>
              MapEntry(key.toString(), value.toString()));
        } else {
          throw Exception('Invalid "text" field format');
        }
      }else if (response.statusCode == 404) {
        print("No Answers Found");
        return {};
      } else {
        // Log and throw exception for failed response
        final errorMessage = "Failed to fetch answers: "
            "Status Code: ${response.statusCode}, "
            "Response: ${response.body}";
        print(errorMessage);
        throw Exception(errorMessage);
      }
    } catch (e, stackTrace) {
      // Log the error with stack trace for debugging
      print("Error fetching answers: $e\n$stackTrace");
      rethrow; // Optionally rethrow to let the caller handle it
    }
  }
}
