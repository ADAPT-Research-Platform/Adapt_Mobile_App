import 'package:flutter/material.dart';

import '../models/module.dart';
import '../models/section.dart';
import '../utils/app_colors.dart';
import '../utils/app_routes.dart';
import '../utils/app_keys.dart';
import '../widgets/section_card.dart';
import '../widgets/main_title.dart';
import '../widgets/sub_title.dart';

class ModulePage extends StatefulWidget {
  final Module module;

  const ModulePage({super.key, required this.module});

  @override
  _ModulePageState createState() => _ModulePageState();
}

class _ModulePageState extends State<ModulePage> {
  String selectedFilter = 'All'; // Default filter

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: MainTitle(
        title: 'Module ${widget.module.moduleId}',
        leadingIcon: Icons.arrow_back_ios,
        onIconPressed: () {
          moduleNavigator.currentState!.pop(); // Go Backwards
        },
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Column(
          children: [
            // Segmented Button to filter chapters
            SegmentedButton<String>(
              style: SegmentedButton.styleFrom(
                backgroundColor: AppColors.darkWhite,
                foregroundColor: AppColors.fontColor,
                selectedForegroundColor: AppColors.fontColor,
                selectedBackgroundColor: AppColors.primaryYellow,
                side: const BorderSide(
                  color: AppColors.darkYellow, // Set the border color
                  width: 2.2,                 // Set the border width
                ),
              ),
              segments: const <ButtonSegment<String>> [
                ButtonSegment(
                    value: 'All',
                    label: SizedBox(
                      width: 70, // Fixed width
                      child: Center(child: Text('All')),
                    )
                ),
                ButtonSegment(
                    value: 'Readings',
                    label: SizedBox(
                      width: 70, // Fixed width
                      child: Center(child: Text('Readings')),
                    )
                ),
                ButtonSegment(
                    value: 'Exercises',
                    label: SizedBox(
                      width: 70, // Fixed width
                      child: Center(child: Text('Exercises')),
                    )
                ),
              ],
              selected: <String>{selectedFilter},
              onSelectionChanged: (Set<String> newSelection) {
                setState(() {
                  selectedFilter = newSelection.first; // Update filter
                });
              },
            ),
            const Divider(
              color: AppColors.lightGrey,
              // Customize the color as needed
              thickness: 2.5, // Customize the thickness as needed
            ),
            Expanded(
              child: ListView.builder(
                itemCount: widget.module.chapters.length,
                itemBuilder: (context, chapterIndex) {
                  final chapter = widget.module.chapters[chapterIndex];

                  // Filter sections based on the selected filter
                  Map<int, Section> filteredSectionsMap = {};
                  // Show all sections, maintain the original index
                  for (int i = 0; i < chapter.sections.length; i++) {
                    if (selectedFilter == 'All') {
                      filteredSectionsMap[i] = chapter.sections[i];
                    } else if (selectedFilter == 'Readings' && !chapter.sections[i].isExercise) {
                      filteredSectionsMap[i] = chapter.sections[i];
                    } else if (selectedFilter == 'Exercises' && chapter.sections[i].isExercise) {
                      filteredSectionsMap[i] = chapter.sections[i];
                    }
                  }
                  
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
                        itemCount: filteredSectionsMap.length,
                        itemBuilder: (context, index) {
                          final section = filteredSectionsMap.values.elementAt(index);
                          final sectionIndex = filteredSectionsMap.keys.elementAt(index);
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
