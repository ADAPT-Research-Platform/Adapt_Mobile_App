
class Answer {
  final String chapterId;
  final String moduleId;
  final String chapterIndex;
  final DateTime timeStamp;
  final Map<String, String> text; //Question Key and Answer

  Answer({
    required this.chapterId,
    required this.moduleId,
    required this.chapterIndex,
    required this.timeStamp,
    required this.text,
  });

  factory Answer.parse(Map<String, dynamic> json) {
    return Answer(
      chapterId: json['chapterId'].toString(),
      moduleId: json['moduleId'].toString(),
      chapterIndex: json['chapterIndex'].toString(),
      timeStamp: DateTime.parse(json['updatedAt']),
      text: Map<String, String>.from(json['text']),
    );
  }
}
