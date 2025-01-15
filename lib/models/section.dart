class Section {
  final String sectionId;
  final DateTime timeStamp;
  final String folderPath; //Section Folder URL (Very Important)
  final String title;
  final bool isExercise;
  final double progress;
  String sectionName = "Unknown"; //Need to figure out this

  Section({
    required this.sectionId,
    required this.timeStamp,
    required this.folderPath,
    required this.title,
    required this.progress,
    required this.isExercise
  });
}
