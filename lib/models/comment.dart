
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

  factory Comment.parse(Map<String, dynamic> json) {
    return Comment(
      commentId: json['id'].toString(),
      commentUserName: json['commentUserName'],
      timeStamp: DateTime.parse(json['createdAt']),
      text: json['text'] ?? '',
      comments: (json['replies'] as List<dynamic>)
          .map((chapterJson) => Comment.parse(chapterJson))
          .toList(),
    );
  }
}
