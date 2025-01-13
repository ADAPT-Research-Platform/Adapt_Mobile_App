import 'package:adapt/models/user.dart';

class Comment {
  final String commentId;
  final String commentUserName;
  final DateTime timeStamp;
  final String text;
  List<Comment> comments;

  Comment({
    required this.commentId,
    required this.commentUserName,
    required this.timeStamp,
    required this.text,
    this.comments = const [], // Default value set to an empty list
  });
}
