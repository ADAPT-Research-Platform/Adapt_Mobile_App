
class Chapter {
  final String chapterId;
  final String chapterIndex;
  final DateTime timeStamp;
  final String folderPath; //Section Folder URL (Very Important)
  final String title;
  final bool isExercise;
  final double progress;
  final int numOfComments;

  Chapter({
    required this.chapterId,
    required this.chapterIndex,
    required this.timeStamp,
    required this.folderPath,
    required this.title,
    required this.progress,
    required this.numOfComments,
    required this.isExercise
  });

  factory Chapter.parse(Map<String, dynamic> json) {
    return Chapter(
      chapterId: json['id'].toString(),
      chapterIndex: json['index'].toString(),
      timeStamp: DateTime.parse(json['updatedAt']),
      folderPath: json['folderUrl'] ?? '',
      title: json['title'] ?? '',
      progress: (json['progress'] as num).toDouble(),
      numOfComments: (json['numOfComments'] as num).toInt(),
      isExercise: json['isExercise'] ?? false,
    );
  }
}
