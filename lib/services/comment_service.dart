import 'dart:convert';
import 'dart:io';

import 'package:adapt/services/session_manager.dart';
import 'package:logging/logging.dart';

import '../models/comment.dart';
import '../utils/app_config.dart';
import '../utils/app_keys.dart';
import '../widgets/snack_bar_shower.dart';

class CommentService {
  final log = Logger('CommentService');

  void addComment(String text, String chapterId) async {
    try {
      final response = await SessionManager().client.post(
        Uri.parse('${AppConfig.baseUrl}/comments'),
        headers: SessionManager().getHeaders(),
        body: jsonEncode({
          'text': text,
          'chapterId': chapterId,
        }),
      );

      log.info('Add Comment Response: ${response.body}');
      if (response.statusCode == 201) {
        SnackBarShower.info(mainPageScaffold, 'Comment Added Successfully!');
      } else {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        SnackBarShower.error(mainPageScaffold, jsonResponse['message']);
      }
    } catch (e) {
      log.severe('Error in Comment Add', e);
      SnackBarShower.error(mainPageScaffold, 'Internal App Error!');
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

      log.info('Add Reply Response: ${response.body}');
      if (response.statusCode == 201) {
        SnackBarShower.info(mainPageScaffold, 'Reply Added Successfully!');
      } else {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        SnackBarShower.error(mainPageScaffold, jsonResponse['message']);
      }
    } catch (e) {
      log.severe('Error in Reply Add', e);
      SnackBarShower.error(mainPageScaffold, 'Internal App Error!');
    }
  }

  Future<List<Comment>> fetchComments({String? chapterId, DateTime? date}) async {
    // Add query parameters
    final Map<String, String> queryParams = {};
    if (chapterId != null) {
      queryParams['chapterId'] = chapterId;
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
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        log.severe('Error in Get Comments By ChapterId', jsonResponse['message']);
        throw HttpException(jsonResponse['message']);
      }
    } catch (e) {
      log.severe('Error in Get Comments By ChapterId', e);
      rethrow;
    }
  }
}
