import 'package:flutter/material.dart';

import '../models/module.dart';
import '../utils/app_colors.dart';
import '../utils/app_font_sizes.dart';
import '../utils/app_routes.dart';
import '../utils/navigator_keys.dart';
import '../utils/string_formatter.dart';
import '../widgets/app_exercise_card.dart';
import '../widgets/app_title_bar.dart';

class ModulePage extends StatelessWidget {
  final Module module;

  const ModulePage({
    super.key,
    required this.module,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppTitleBar(
        title: convertIdToName(module.id),
        leadingIcon: Icons.arrow_back_ios,
        onIconPressed: (){
          moduleNavigatorKey.currentState!.pop(); //Go Backwards
        }
      ),
      body: Column(
        children: [
           Center(
            child: Text(
              module.title,
              style: TextStyle(
                color: AppColors.darkYellow, // Static text color
                fontSize: AppFontSizes.medium, // Static font size
                fontWeight: FontWeight.bold, // Static font weight
              ),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18.0),
                // Adds margin to ListView
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
                            moduleNavigatorKey.currentState!.pushNamed(Routes.beehiveExercises, arguments: exercise);
                          },
                        ));
                  },
                ),
              )),
        ],
      ),
    );
  }
}
