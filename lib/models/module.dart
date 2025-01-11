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
}
