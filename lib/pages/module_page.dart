import 'package:flutter/material.dart';

import '../models/module.dart';
import '../utils/app_colors.dart';
import '../utils/app_routes.dart';
import '../utils/app_keys.dart';
import '../utils/string_formatter.dart';
import '../widgets/section_card.dart';
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
        title: 'Module ${module.moduleId}',
        leadingIcon: Icons.arrow_back_ios,
        onIconPressed: () {
          moduleNavigator.currentState!.pop(); // Go Backwards
        },
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: module.chapters.length,
                itemBuilder: (context, chapterIndex) {
                  final chapter = module.chapters[chapterIndex];

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Chapter Title
                      SubTitle(text: 'Chapter ${chapterIndex + 1}' ),
                      const SizedBox(height: 8),

                      // List of sections under the chapter
                      ListView.builder(
                        shrinkWrap: true,  // Prevents expansion and allows for vertical scrolling only
                        physics: const NeverScrollableScrollPhysics(),  // Disable scrolling inside the chapter list
                        itemCount: chapter.sections.length,
                        itemBuilder: (context, sectionIndex) {
                          final section = chapter.sections[sectionIndex];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10.0),
                            child: SectionCard(
                              sectionIndex: sectionIndex,
                              section: section,
                              onPressed: () {
                                moduleNavigator.currentState!.pushNamed(
                                  Routes.routeExercises,
                                  arguments: section,
                                );
                              },
                            ),
                          );
                        },
                      ),

                      // Divider after each chapter
                      const Divider(
                        color: AppColors.lightGrey,
                        thickness: 2.5,
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );

  }
}
