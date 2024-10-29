import 'package:adapt/models/exercise.dart';
import 'package:adapt/services/firebase_exercise_service.dart';
import 'package:adapt/utils/app_colors.dart';
import 'package:adapt/widgets/app_title_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import '../utils/navigator_keys.dart';
import '../utils/string_formatter.dart';

class ExercisePage extends StatefulWidget {
  final Exercise exercise;

  const ExercisePage({super.key, required this.exercise});

  @override
  _ExercisePageState createState() => _ExercisePageState();
}

class _ExercisePageState extends State<ExercisePage> {
  final ScrollController _scrollController = ScrollController();
  final FirebaseExerciseService _firebaseExerciseService = FirebaseExerciseService();

  double position = 0;

  void _scroll(double offset) {
    position = position + offset;

    if (position < 0) {
      position = 0;
    } else if (position > _scrollController.position.maxScrollExtent) {
      position = _scrollController.position.maxScrollExtent;
    }

    _scrollController.jumpTo(
      position,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppTitleBar(
          title: convertIdToName(widget.exercise.id),
          leadingIcon: Icons.arrow_back_ios,
          onIconPressed: (){
            moduleNavigatorKey.currentState!.pop(); //Go Backwards
          }),
      body: FutureBuilder<String>(
        future: _firebaseExerciseService.fetchExerciseFile(widget.exercise.url),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppColors.darkYellow));
          } else if (snapshot.hasError) {
            return const Center(child: Text("Error loading exercise"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No exercise available"));
          }

          final markdownContent = snapshot.data!;

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  controller: _scrollController,
                  child: MarkdownBody(
                    data: markdownContent,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back_ios,
                          color: AppColors.darkYellow, size: 25), // Static color
                      onPressed: () => _scroll(-250),
                    ),
                    IconButton(
                      icon: Icon(Icons.arrow_forward_ios,
                          color: AppColors.darkYellow, size: 25), // Static color
                      onPressed: () => _scroll(250),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      )
    );
  }
}
