import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

import '../models/module.dart';
import '../models/section.dart';
import '../services/module_service.dart';
import '../utils/app_colors.dart';
import '../utils/app_keys.dart';
import '../utils/app_routes.dart';
import '../widgets/main_title.dart';
import '../widgets/section_card.dart';
import '../widgets/sub_title.dart';

class ChapterPage extends StatefulWidget {
  final String moduleId;

  const ChapterPage({super.key, required this.moduleId});

  @override
  _ChapterPageState createState() => _ChapterPageState();
}

class _ChapterPageState extends State<ChapterPage> {
  final log = Logger('ChapterPage');

  final ModuleService _moduleService = ModuleService();
  String selectedFilter = 'All'; // Default filter

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MainTitle(
        title: 'Module ${widget.moduleId}',
        leadingIcon: Icons.arrow_back_ios_rounded,
        onIconPressed: () {
          moduleNavigator.currentState!.pop(); // Go Backwards
        },
      ),
      body: FutureBuilder<Module>(
          future: _moduleService.fetchModuleById(widget.moduleId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: AppColors.darkYellow));
            } else if (snapshot.hasError) {
              return const Center(child: Text("Error loading chapters"));
            } else if (!snapshot.hasData) {
              return const Center(child: Text("No chapters available"));
            }

            final module = snapshot.data!;

            return Padding(
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
                          width: 2.2, // Set the border width
                        ),
                      ),
                      segments: const <ButtonSegment<String>>[
                        ButtonSegment(
                            value: 'All',
                            label: SizedBox(
                              width: 70, // Fixed width
                              child: Center(child: Text('All')),
                            )),
                        ButtonSegment(
                            value: 'Readings',
                            label: SizedBox(
                              width: 70, // Fixed width
                              child: Center(child: Text('Readings')),
                            )),
                        ButtonSegment(
                            value: 'Exercises',
                            label: SizedBox(
                              width: 70, // Fixed width
                              child: Center(child: Text('Exercises')),
                            )),
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
                        itemCount: module.chapters.length,
                        itemBuilder: (context, chapterIndex) {
                          final chapter = module.chapters[chapterIndex];

                          // Filter sections based on the selected filter
                          Map<int, Section> filteredSectionsMap = {};
                          // Show all sections, maintain the original index
                          for (int i = 0; i < chapter.sections.length; i++) {
                            if (selectedFilter == 'All') {
                              filteredSectionsMap[i] = chapter.sections[i];
                            } else if (selectedFilter == 'Readings' &&
                                !chapter.sections[i].isExercise) {
                              filteredSectionsMap[i] = chapter.sections[i];
                            } else if (selectedFilter == 'Exercises' &&
                                chapter.sections[i].isExercise) {
                              filteredSectionsMap[i] = chapter.sections[i];
                            }
                          }

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 8),
                              // Chapter Title
                              SubTitle(text: 'Chapter ${chapterIndex + 1}'),
                              const SizedBox(height: 8),

                              // List of sections under the chapter
                              ListView.builder(
                                shrinkWrap: true,
                                // Prevents expansion and allows for vertical scrolling only
                                physics: const NeverScrollableScrollPhysics(),
                                // Disable scrolling inside the chapter list
                                itemCount: filteredSectionsMap.length,
                                itemBuilder: (context, index) {
                                  final section = filteredSectionsMap.values.elementAt(index);
                                  final sectionIndex = filteredSectionsMap.keys.elementAt(index);
                                  section.sectionName = section.isExercise ? 'Section ${sectionIndex + 1}: Exercise' : 'Section ${sectionIndex + 1}';

                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 10.0),
                                    child: SectionCard(
                                      section: section,
                                      onPressed: () {
                                        moduleNavigator.currentState!.pushNamed(Routes.routeSections, arguments: section);
                                      },
                                    ),
                                  );
                                },
                              ),
                              // Progress and Answers Row
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.access_time_filled_rounded, color: AppColors.darkYellow),
                                      const SizedBox(width: 4),
                                      Text(
                                        "${chapter.progress.round()}% Progress",
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: AppColors.fontColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(width: 8),
                                  Row(
                                    children: [
                                      const Icon(Icons.list_alt_rounded, color: AppColors.darkYellow),
                                      const SizedBox(width: 4),
                                      Text(
                                        "${chapter.numOfComments} Comments",
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: AppColors.fontColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
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
                ));
          }),
    );
  }
}
