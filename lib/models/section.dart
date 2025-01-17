class Section {
  final String sectionId;
  final DateTime timeStamp;
  final String folderPath; //Section Folder URL (Very Important)
  final String title;
  final bool isExercise;
  final double progress;
  final int numOfComments;
  String sectionName = "Unknown"; //Need to figure out this

  Section({
    required this.sectionId,
    required this.timeStamp,
    required this.folderPath,
    required this.title,
    required this.progress,
    required this.numOfComments,
    required this.isExercise
  });

  factory Section.parse(Map<String, dynamic> json) {
    return Section(
      sectionId: json['id'].toString(),
      timeStamp: DateTime.parse(json['updatedAt']),
      folderPath: json['folderUrl'] ?? '',
      title: json['title'] ?? '',
      progress: (json['progress'] as num).toDouble(),
      numOfComments: (json['numOfComments'] as num).toInt(),
      isExercise: json['isExercise'] ?? false,
    );
  }
}
