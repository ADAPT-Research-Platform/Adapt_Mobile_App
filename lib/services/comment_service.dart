import 'dart:convert';

import 'package:adapt/services/session_manager.dart';
import 'package:logging/logging.dart';

import '../models/comment.dart';
import '../utils/app_config.dart';

class CommentService {
  final log = Logger('CommentService');

  void addComment(String text, String sectionId) async {

    try {
      final response = await SessionManager().client.post(
        Uri.parse('${AppConfig.baseUrl}/comments'),
        headers: SessionManager().getHeaders(),
        body: jsonEncode({
          'text': text,
          'sectionId': sectionId,
        }),
      );

      if (response.statusCode == 200) {
        log.info('Comment updated successfully!');
      }else if (response.statusCode == 201) {
        log.info('Comment added successfully!');
      } else if (response.statusCode == 400) {
        log.severe('Bad Request: ${response.body}');
      } else {
        log.severe('Comment adding failed: ${response.statusCode}, ${response.body}');
      }
    } catch (e) {
      log.severe('Error during adding/updating Comment: $e');
    }
  }

  void addReply(String text, String parentCommentId) async {
    try {
      final response = await SessionManager().client.post(
        Uri.parse('${AppConfig.baseUrl}/comments/reply'),
        headers: SessionManager().getHeaders(),
        body: jsonEncode({
          'text': text,
          'parentCommentId': parentCommentId,
        }),
      );

      if (response.statusCode == 200) {
        log.info('Reply updated successfully!');
      }else if (response.statusCode == 201) {
        log.info('Reply added successfully!');
      } else if (response.statusCode == 400) {
        log.severe('Bad Request: ${response.body}');
      } else {
        log.severe('Reply adding failed: ${response.statusCode}, ${response.body}');
      }
    } catch (e) {
      log.severe('Error during adding/updating Reply: $e');
    }
  }

  Future<List<Comment>> fetchComments({String? sectionId, DateTime? date}) async {
    // Add query parameters
    final Map<String, String> queryParams = {};
    if (sectionId != null) {
      queryParams['sectionId'] = sectionId;
    }

    if (date != null) {
      queryParams['date'] = date.toIso8601String(); // Format as YYYY-MM-DD
    }

    try {
      final response = await SessionManager().client.get(
        Uri.parse('${AppConfig.baseUrl}/comments').replace(queryParameters: queryParams),
        headers: SessionManager().getHeaders(),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Comment.parse(json)).toList();
      } else {
        // Log and throw exception for failed response
        final errorMessage = "Failed to fetch comments: "
            "Status Code: ${response.statusCode}, "
            "Response: ${response.body}";
        log.severe(errorMessage);
        throw Exception(errorMessage);
      }
    } catch (e, stackTrace) {
      // Log the error with stack trace for debugging
      log.severe("Error fetching comments: $e\n$stackTrace");
      rethrow; // Optionally rethrow to let the caller handle it
    }
  }
}
