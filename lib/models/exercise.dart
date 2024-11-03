
import 'module.dart';

class Exercise {
  final String exerciseId;
  final DateTime timeStamp;
  final String url; //Markdown File URL
  final String title;
  final double progress;

  Exercise({
    required this.exerciseId,
    required this.timeStamp,
    required this.url,
    required this.title,
    required this.progress
  });
}
