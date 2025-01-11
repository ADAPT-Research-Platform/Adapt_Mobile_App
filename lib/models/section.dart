import 'comment.dart';

class Section {
  final String sectionId;
  final DateTime timeStamp;
  final String url; //Section Folder URL (Very Important)
  final String title;
  final bool isExercise;

  Section({
    required this.sectionId,
    required this.timeStamp,
    required this.url,
    required this.title,
    required this.isExercise
  });
}
