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
import '../utils/app_colors.dart';
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MainTitle(title: LocalizationService().get('overview')),
      body: FutureBuilder<List<String>>(
        future: _modulesIdFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppColors.darkYellow));
          } else if (snapshot.hasError) {
            return const Center(child: Text("Error loading modules!"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No data available!"));
          }

          final moduleIdList = snapshot.data!;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SubTitle(text: LocalizationService().get('Modules')),
                  ModuleGrid(
                    moduleIdList: moduleIdList,
                    size: MediaQuery.of(context).size.width / 4, // Adjust dynamically
                  ),
                  const Divider(
                    color: AppColors.lightGrey,
                    thickness: 2.5,
                  ),
                  //Expanded(child: Container()),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SubTitle(text: LocalizationService().get('everyday_questions')),
                      const SizedBox(height: 10),
                      Text(
                        LocalizationService().get('im_feeling_today'),
                        style: const TextStyle(
                          color: AppColors.fontColor,
                          fontSize: AppFontSizes.small,
                        ),
                      ),
                      const SizedBox(height: 10),
                      // Feeling Selector Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildFeelingIcon(Feeling.happy, Icons.sentiment_satisfied_alt),
                          _buildFeelingIcon(Feeling.sad, Icons.sentiment_dissatisfied),
                          _buildFeelingIcon(Feeling.angry, Icons.sentiment_very_dissatisfied),
                          _buildFeelingIcon(Feeling.tired, Icons.sentiment_neutral),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Text(
                        LocalizationService().get('im_motivated_today'),
                        style: const TextStyle(
                          color: AppColors.fontColor,
                          fontSize: AppFontSizes.small,
                        ),
                      ),
                      StarSlider(
                        sliderLength: MoodService.maxMotivation,
                        onChanged: (value) {
                          setState(() {
                            _selectedMotivation = value;
                          });
                        },
                      ),
                      const SizedBox(height: 20),
                      TaskButton(
                        text: LocalizationService().get('Submit'),
                        onPressed: () {
                          _modeService.saveMode(_selectedFeeling, _selectedMotivation);

                          widget.reloadModePage();
                          // Schedule a notification for the next day
                          DateTime scheduledDate = DateTime.now().add( const Duration(days: 1));
                          NotificationService.scheduleNotification(
                            0,
                            "Time to log your Mood and Motivation",
                            "Don't forget to log your mood and motivation for today!",
                            scheduledDate,
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFeelingIcon(Feeling feeling, IconData icon) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFeeling = _selectedFeeling == feeling ? Feeling.none : feeling;
        });
      },
      child: Column(
        children: [
          Icon(
            icon,
            color: _selectedFeeling == feeling ? AppColors.primaryYellow : AppColors.darkGrey,
            size: 40,
          ),
          Text(
            feeling.value,
            style: TextStyle(
              color: _selectedFeeling == feeling ? AppColors.darkYellow : AppColors.darkGrey,
            ),
          ),
        ],
      ),
    );
  }
}
