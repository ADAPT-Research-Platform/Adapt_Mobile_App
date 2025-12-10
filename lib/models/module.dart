

import 'package:adapt/models/chapter.dart';

class Module {
  final String moduleId;
  final double progress;
  List<Chapter> chapters;

  Module({
    required this.moduleId,
    required this.progress,
    required this.chapters
  });

  factory Module.parse(Map<String, dynamic> json, Map<String, dynamic> titles) {
    List<Chapter> chapters = (json['chapters'] as List<dynamic>)
        .map((chapterJson) => Chapter.parse(chapterJson, titles[chapterJson['index'].toString()]))
        .toList();

    // Calculate the average progress of the module based on its chapters' progress
    double moduleProgress = 0.0;
    if (chapters.isNotEmpty) {
      moduleProgress = chapters.fold(0.0, (sum, chapter) => sum + chapter.progress) / chapters.length;
    }

    return Module(
      moduleId: json['id'].toString(),
      progress: moduleProgress,
      chapters: chapters,
    );
  }
}
