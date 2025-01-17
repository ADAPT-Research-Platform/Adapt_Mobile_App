import 'section.dart';

class Chapter {
  final String chapterId;
  final String title;
  final double progress;
  final int numOfComments;
  List<Section> sections; //Either Readings or Exercises

  Chapter({
    required this.chapterId,
    required this.title,
    required this.progress,
    required this.numOfComments,
    required this.sections
  });

  factory Chapter.parse(Map<String, dynamic> json) {
    List<Section> sections = (json['sections'] as List<dynamic>)
        .map((sectionJson) => Section.parse(sectionJson))
        .toList();

    // Calculate the average progress of the chapter based on its sections' progress
    double chapterProgress = 0.0;
    int chapterNumOfComments = 0;
    if (sections.isNotEmpty) {
      chapterProgress = sections.fold(0.0, (sum, section) => sum + section.progress) / sections.length;
      chapterNumOfComments = sections.fold(0, (sum, section) => sum + section.numOfComments);
    }

    return Chapter(
      chapterId: json['id'].toString(),
      title: json['title'] ?? '',
      progress: chapterProgress,
      numOfComments: chapterNumOfComments,
      sections: sections,
    );
  }
}
