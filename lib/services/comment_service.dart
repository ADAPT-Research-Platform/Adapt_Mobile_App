import 'dart:convert';

import 'package:adapt/services/session_manager.dart';

import '../models/comment.dart';
import '../utils/app_config.dart';

class CommentService {

  void addComment(String text, String sectionId) async {
    try {
      final response = await SessionManager().client.post(
        Uri.parse('${AppConfig.baseUrl}/api/comments'),
        headers: SessionManager().getHeaders(),
        body: jsonEncode({
          'text': text,
          'sectionId': sectionId,
        }),
      );

      if (response.statusCode == 201) {
        print('Comment added successful!');
      } else if (response.statusCode == 400) {
        print('Bad Request: ${response.body}');
        // Handle validation errors from the server response
      } else {
        print('Comment adding failed: ${response.statusCode}, ${response.body}');
      }
    } catch (e) {
      print('Error during commenting: $e');
    }
  }

  void addReply(String text, String parentCommentId) async {
    try {
      final response = await SessionManager().client.post(
        Uri.parse('${AppConfig.baseUrl}/api/comments'),
        headers: SessionManager().getHeaders(),
        body: jsonEncode({
          'text': text,
          'parentCommentId': parentCommentId,
        }),
      );

      if (response.statusCode == 201) {
        print('Reply added successful!');
      } else if (response.statusCode == 400) {
        print('Bad Request: ${response.body}');
        // Handle validation errors from the server response
      } else {
        print('Reply adding failed: ${response.statusCode}, ${response.body}');
      }
    } catch (e) {
      print('Error during replying: $e');
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
        Uri.parse('${AppConfig.baseUrl}/api/comments').replace(queryParameters: queryParams),
        headers: SessionManager().getHeaders(),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => parseComment(json)).toList();
      } else {
        // Log and throw exception for failed response
        final errorMessage = "Failed to fetch comments: "
            "Status Code: ${response.statusCode}, "
            "Response: ${response.body}";
        print(errorMessage);
        throw Exception(errorMessage);
      }
    } catch (e, stackTrace) {
      // Log the error with stack trace for debugging
      print("Error fetching comments: $e\n$stackTrace");
      rethrow; // Optionally rethrow to let the caller handle it
    }
  }

  Comment parseComment(Map<String, dynamic> json) {
    return Comment(
      commentId: json['id'].toString(),
      commentUserName: json['commentUserName'],
      timeStamp: DateTime.parse(json['createdAt']),
      text: json['text'] ?? '',
      comments: (json['replies'] as List<dynamic>)
          .map((chapterJson) => parseComment(chapterJson))
          .toList(),
    );
  }
}
