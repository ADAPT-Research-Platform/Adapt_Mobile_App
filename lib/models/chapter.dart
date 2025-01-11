import 'section.dart';

class Chapter {
  final String chapterId;
  final String title;
  final double progress;
  List<Section> sections; //Either Readings or Exercises

  Chapter({
    required this.chapterId,
    required this.title,
    required this.progress,
    required this.sections
  });
}
