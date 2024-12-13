import 'package:flutter/material.dart';

import '../models/module.dart';
import '../utils/app_colors.dart';
import '../utils/app_font_sizes.dart';
import '../utils/app_routes.dart';
import '../utils/app_keys.dart';
import '../utils/string_formatter.dart';
import '../widgets/exercise_card.dart';
import '../widgets/main_title.dart';
import '../widgets/sub_title.dart';

class ModulePage extends StatelessWidget {
  final Module module;

  const ModulePage({
    super.key,
    required this.module,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: MainTitle(
            title: convertIdToName(module.moduleId),
            leadingIcon: Icons.arrow_back_ios,
            onIconPressed: () {
              moduleNavigator.currentState!.pop(); //Go Backwards
            }),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Column(
            children: [
              SubTitle(text: module.title),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
                  itemCount: module.exercises.length,
                  itemBuilder: (context, index) {
                    final exercise = module.exercises[index];
                    return Padding(
                        padding: const EdgeInsets.only(bottom: 10.0),
                        // Adds gap between cards
                        child: ExerciseCard(
                          title: exercise.title,
                          period: "${DateTime.now().difference(exercise.timeStamp).inDays} Days Ago",
                          answers: 2, //Hard Coded
                          progress: 0.75, //Hard Coded
                          onPressed: () {
                            moduleNavigator.currentState!.pushNamed(Routes.routeExercises, arguments: exercise);
                          },
                        ));
                  },
                ),
              ),
            ],
          ),
        ));
  }
}
