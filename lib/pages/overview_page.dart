import 'package:adapt/widgets/module_grid.dart';
import 'package:adapt/widgets/star_slider.dart';
import 'package:flutter/material.dart';

import '../models/module.dart';
import '../services/firebase_mode_service.dart';
import '../services/firebase_module_service.dart';
import '../utils/app_colors.dart';
import '../utils/app_font_sizes.dart';
import '../widgets/app_title_bar.dart';

class OverviewPage extends StatefulWidget {
  const OverviewPage({super.key});

  @override
  _OverviewPageState createState() => _OverviewPageState();
}

class _OverviewPageState extends State<OverviewPage> {
  final FirebaseModuleService _firebaseModuleService = FirebaseModuleService();
  final FirebaseModeService _firebaseModeService = FirebaseModeService();

  int _selectedFeeling = 0; // 0 for no selection, 1 for happy, 2 for sad, etc.
  int _selectedMotivation = 5;

  late Future<List<Module>> _modulesFuture; // Declare the Future

  @override
  void initState() {
    super.initState();
    _modulesFuture =
        _firebaseModuleService.fetchModuleList(); // Initialize the Future
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: const AppTitleBar(title: 'Overview'),
        body: FutureBuilder<List<Module>>(
          future: _modulesFuture, // Use the initialized Future here
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                  child:
                      CircularProgressIndicator(color: AppColors.darkYellow));
            } else if (snapshot.hasError) {
              return const Center(child: Text("Error loading modules"));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text("No modules available"));
            }

            final modules = snapshot.data!;

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                  //mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      'Modules',
                      style: TextStyle(
                        color: AppColors.darkYellow, // Static text color
                        fontSize: AppFontSizes.medium, // Static font size
                        fontWeight: FontWeight.bold, // Static font weight
                      ),
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.28,
                      child: ModuleGrid(
                        modules: modules,
                        size: 100,
                        fillColor: AppColors.primaryYellow,
                        icon: Icons.play_arrow_rounded,
                        strokeRadius: 5,
                        iconColor: AppColors.darkYellow,
                      ),
                    ),
                    const Divider(
                      color: AppColors.lightGrey,
                      // Customize the color as needed
                      thickness: 2.5, // Customize the thickness as needed
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text(
                          'Everyday Questions',
                          style: TextStyle(
                            color: AppColors.darkYellow, // Static text color
                            fontSize: AppFontSizes.medium, // Static font size
                            fontWeight: FontWeight.bold, // Static font weight
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'I’m feeling today.',
                          style: TextStyle(
                            color: AppColors.fontColor, // Static text color
                            fontSize: AppFontSizes.small, // Static font size
                          ),
                        ),
                        const SizedBox(height: 10),
                        // Feeling Selector Row
                        Row(
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
                        const SizedBox(height: 20),
                        const Text(
                          'I’m motivated today.',
                          style: TextStyle(
                            color: AppColors.fontColor, // Static text color
                            fontSize: AppFontSizes.small, // Static font size
                          ),
                        ),
                        StarSlider(
                          sliderLength: 5, //How many stars
                          onChanged: (value) {
                            setState(() {
                              _selectedMotivation = value;
                            });
                          },
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {
                            //TODO: Need to set userId dynamically
                            _firebaseModeService.saveMode(
                                'xZOnZ2mQvTWTObfryho7tbetU1V2',
                                _selectedFeeling,
                                _selectedMotivation);
                            print('Selected Feeling: $_selectedFeeling');
                            print('Motivation Rating: $_selectedMotivation');
                          },
                          style: ElevatedButton.styleFrom(
                            foregroundColor: AppColors.white,
                            backgroundColor: AppColors.primaryYellow,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6.0),
                            ),
                            minimumSize: Size(double.infinity, 50),
                          ),
                          child: const Text(
                            'Submit',
                            style: TextStyle(
                              fontSize: AppFontSizes.small,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ]),
            );
          },
        ));
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
