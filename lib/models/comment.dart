import 'package:adapt/models/user.dart';

class Comment {
  final String commentId;
  final User user;
  final DateTime timeStamp;
  final String text;
  List<Comment> replies;

  Comment({
    required this.commentId,
    required this.user,
    required this.timeStamp,
    required this.text,
    this.replies = const [], // Default value set to an empty list
  });
}
