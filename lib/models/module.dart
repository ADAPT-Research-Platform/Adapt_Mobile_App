import 'exercise.dart';

class Module {
  final String moduleId;
  final String title;
  List<Exercise> exercises;

  Module({
    required this.moduleId,
    required this.title,
    required this.exercises
  });
}
