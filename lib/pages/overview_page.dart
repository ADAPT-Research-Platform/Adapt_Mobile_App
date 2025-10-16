import 'package:adapt/widgets/module_grid.dart';
import 'package:adapt/widgets/star_slider.dart';
import 'package:adapt/widgets/task_button.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

import '../enums/feeling.dart';
import '../services/localization_service.dart';
import '../services/module_service.dart';
import '../services/mood_service.dart';
import '../services/notification_service.dart';
import '../utils/app_font_sizes.dart';
import '../widgets/main_title.dart';
import '../widgets/sub_title.dart';

class OverviewPage extends StatefulWidget {
  final VoidCallback reloadModePage;

  const OverviewPage({super.key, required this.reloadModePage});

  @override
  _OverviewPageState createState() => _OverviewPageState();
}

class _OverviewPageState extends State<OverviewPage> {
  final log = Logger('OverviewPage');

  final ModuleService _moduleService = ModuleService();
  final MoodService _modeService = MoodService();

  Feeling _selectedFeeling = Feeling.none;
  int _selectedMotivation = 0;

  late Future<List<String>> _modulesIdFuture; // Declare the Future

  @override
  void initState() {
    super.initState();
    _modulesIdFuture = _moduleService.fetchModuleIdList(); // Initialize the Future

    NotificationService.updateMoodScheduledTime();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MainTitle(title: LocalizationService().get('overview')),
      body: FutureBuilder<List<String>>(
        future: _modulesIdFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: Theme.of(context).primaryColorDark));
          } else if (snapshot.hasError) {
            return Center(child: Text(LocalizationService().get("error_loading_modules")));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text(LocalizationService().get("no_modules")));
          }

          final moduleIdList = snapshot.data!;

          return LayoutBuilder(
            builder: (context, constraints) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  children: [
                    // Modules section (shrinks if needed)
                    Flexible(
                      fit: FlexFit.loose,
                      child: Column(
                        children: [
                          SubTitle(text: LocalizationService().get('Modules')),
                          Expanded(
                            child: ModuleGrid(
                              moduleIdList: moduleIdList,
                              // shrink relative to height instead of width
                              //size: moduleSize,
                            ),
                          ),
                        ],
                      ),
                    ),

                    Divider(
                      color: Theme.of(context).dividerColor,
                      thickness: 2.5,
                    ),

                    // Everyday questions section (reserve min height)
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight * 0.4, // at least 35% of screen
                      ),
                      child: Padding( // <--- Wrap the Column with Padding
                        padding: const EdgeInsets.only(bottom: 16.0), // <--- Add your desired bottom padding here
                        child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          SubTitle(text: LocalizationService().get('everyday_questions')),
                          Text(
                            LocalizationService().get('im_feeling_today'),
                            style: const TextStyle(fontSize: AppFontSizes.small),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildFeelingIcon(Feeling.happy),
                              _buildFeelingIcon(Feeling.sad),
                              _buildFeelingIcon(Feeling.angry),
                              _buildFeelingIcon(Feeling.tired),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Text(
                            LocalizationService().get('im_motivated_today'),
                            style: const TextStyle(fontSize: AppFontSizes.small),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                          StarSlider(
                            sliderLength: MoodService.maxMotivation,
                            onChanged: (value) {
                              setState(() {
                                _selectedMotivation = value;
                              });
                            },
                          ),
                          const SizedBox(height: 10),
                          TaskButton(
                            text: LocalizationService().get('Submit'),
                            onPressed: () {
                              _modeService.saveMode(_selectedFeeling, _selectedMotivation);
                              widget.reloadModePage();
                            },
                          ),
                        ],
                      ),
                    )
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildFeelingIcon(Feeling feeling) {
    return Flexible(
        child: GestureDetector(
          onTap: () {
            setState(() {
              _selectedFeeling = _selectedFeeling == feeling ? Feeling.none : feeling;
            });
          },
          child: Column(
            children: [
              Icon(
                feeling.iconData,
                color: _selectedFeeling == feeling ? Theme.of(context).primaryColorLight : Theme.of(context).highlightColor,
                size: 40,
              ),
              Text(
                feeling.value,
                style: TextStyle(
                  color: _selectedFeeling == feeling ? Theme.of(context).primaryColorDark : Theme.of(context).textTheme.displayLarge?.color,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ],
          ),
        )
    );
  }
}
