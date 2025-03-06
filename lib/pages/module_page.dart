import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

import '../enums/section_filter.dart';
import '../models/chapter.dart';
import '../models/module.dart';
import '../services/localization_service.dart';
import '../services/module_service.dart';
import '../utils/app_keys.dart';
import '../utils/app_routes.dart';
import '../widgets/main_title.dart';
import '../widgets/section_card.dart';

class ModulePage extends StatefulWidget {
  final String moduleId;

  const ModulePage({super.key, required this.moduleId});

  @override
  _ModulePageState createState() => _ModulePageState();
}

class _ModulePageState extends State<ModulePage> {
  final log = Logger('ChapterPage');
  final ModuleService _moduleService = ModuleService();

  SectionFilter selectedFilter = SectionFilter.all; // Default filter

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MainTitle(
        title: '${LocalizationService().get('Module')} ${widget.moduleId}',
        leadingIcon: Icons.arrow_back_ios_rounded,
        onIconPressed: () {
          moduleNavigator.currentState!.pop(); // Go Backwards
        },
      ),
      body: FutureBuilder<Module>(
        future: _moduleService.fetchModuleById(widget.moduleId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(color: Theme.of(context).primaryColorDark),
            );
          } else if (snapshot.hasError) {
            return const Center(child: Text("Error loading chapters!"));
          } else if (!snapshot.hasData || snapshot.data!.chapters.isEmpty) {
            return const Center(child: Text("No chapters available!"));
          }

          final module = snapshot.data!;
          final filteredChapters = _getFilteredChapters(module.chapters);

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Column(
              children: [
                _buildSegmentedButton(),
                const SizedBox(height: 5),
                Expanded(
                  child: ListView.builder(
                    itemCount: filteredChapters.length,
                    itemBuilder: (context, index) {
                      final chapter = filteredChapters[index];
                      chapter.chapterName = chapter.isExercise
                          ? '${LocalizationService().get('Chapter')} ${index + 1}: ${LocalizationService().get('Exercise')}'
                          : '${LocalizationService().get('Chapter')} ${index + 1}';

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10.0),
                        child: ChapterCard(
                          chapter: chapter,
                          onPressed: () {
                            moduleNavigator.currentState!.pushNamed(
                              Routes.routeSections,
                              arguments: chapter,
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // Filters the chapters based on the selected filter
  List<Chapter> _getFilteredChapters(List<Chapter> chapters) {
    if (selectedFilter == SectionFilter.all) return chapters;

    return chapters.where((chapter) {
      return selectedFilter == SectionFilter.readings
          ? !chapter.isExercise
          : chapter.isExercise;
    }).toList();
  }

  // Builds the segmented button for filtering
  Widget _buildSegmentedButton() {
    return SegmentedButton<SectionFilter>(
      style: SegmentedButton.styleFrom(
        backgroundColor: Theme.of(context).cardColor,
        foregroundColor: Theme.of(context).textTheme.displayLarge?.color,
        selectedForegroundColor: Theme.of(context).primaryColorDark,
        selectedBackgroundColor: Theme.of(context).primaryColorLight,
        side: BorderSide(
          color: Theme.of(context).primaryColorDark,
          width: 2.2,
        ),
      ),
      segments: SectionFilter.values.map((filter) {
        return ButtonSegment(
          value: filter,
          label: SizedBox(
            width: 70,
            child: Center(child: Text(filter.value)),
          ),
        );
      }).toList(),
      selected: <SectionFilter>{selectedFilter},
      onSelectionChanged: (Set<SectionFilter> newSelection) {
        setState(() {
          selectedFilter = newSelection.first;
        });
      },
    );
  }
}

