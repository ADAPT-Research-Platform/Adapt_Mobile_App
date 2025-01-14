import 'package:adapt/widgets/module_grid.dart';
import 'package:adapt/widgets/star_slider.dart';
import 'package:adapt/widgets/task_button.dart';
import 'package:flutter/material.dart';

import '../models/module.dart';
import '../services/NotificationService.dart';
import '../services/mode_service.dart';
import '../services/module_service.dart';
import '../utils/app_colors.dart';
import '../utils/app_font_sizes.dart';
import '../widgets/main_title.dart';
import '../widgets/sub_title.dart';

class OverviewPage extends StatefulWidget {
  const OverviewPage({super.key});

  @override
  _OverviewPageState createState() => _OverviewPageState();
}

class _OverviewPageState extends State<OverviewPage> {
  final ModuleService _moduleService = ModuleService();
  final ModeService _modeService = ModeService();

  int _selectedFeeling = 0; // 0 for no selection, 1 for happy, 2 for sad, etc.
  int _selectedMotivation = 5;

  late Future<List<Module>> _modulesFuture; // Declare the Future

  @override
  void initState() {
    super.initState();
    _modulesFuture = _moduleService.fetchModuleList(); // Initialize the Future
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MainTitle(title: 'Overview'),
      body: FutureBuilder<List<Module>>(
        future: _modulesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.darkYellow),
            );
          } else if (snapshot.hasError) {
            return const Center(child: Text("Error loading modules"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No modules available"));
          }

          final modules = snapshot.data!;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SubTitle(text: 'Modules'),
                  ModuleGrid(
                    modules: modules,
                    size: MediaQuery.of(context).size.width /
                        4, // Adjust dynamically
                  ),
                  const Divider(
                    color: AppColors.lightGrey,
                    thickness: 2.5,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SubTitle(text: 'Everyday Questions'),
                      const SizedBox(height: 10),
                      const Text(
                        'I’m feeling today.',
                        style: TextStyle(
                          color: AppColors.fontColor,
                          fontSize: AppFontSizes.small,
                        ),
                      ),
                      const SizedBox(height: 10),
                      // Feeling Selector Row
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildFeelingIcon(
                                Icons.sentiment_satisfied_alt, 1, 'Happy'),
                            _buildFeelingIcon(
                                Icons.sentiment_dissatisfied, 2, 'Sad'),
                            _buildFeelingIcon(
                                Icons.sentiment_very_dissatisfied, 3, 'Angry'),
                            _buildFeelingIcon(
                                Icons.sentiment_neutral, 4, 'Tired'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'I’m motivated today.',
                        style: TextStyle(
                          color: AppColors.fontColor,
                          fontSize: AppFontSizes.small,
                        ),
                      ),
                      StarSlider(
                        sliderLength: 5,
                        onChanged: (value) {
                          setState(() {
                            _selectedMotivation = value;
                          });
                        },
                      ),
                      const SizedBox(height: 20),
                      TaskButton(
                        text: 'Submit',
                        onPressed: () {
                          _modeService.saveMode(
                              _selectedFeeling, _selectedMotivation);

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

  Widget _buildFeelingIcon(IconData icon, int feelingValue, String label) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFeeling = feelingValue;
        });
      },
      child: Column(
        children: [
          Icon(
            icon,
            color: _selectedFeeling == feelingValue
                ? AppColors.primaryYellow
                : AppColors.darkGrey,
            size: 40,
          ),
          Text(
            label,
            style: TextStyle(
              color: _selectedFeeling == feelingValue
                  ? AppColors.darkYellow
                  : AppColors.darkGrey,
            ),
          ),
        ],
      ),
    );
  }
}
