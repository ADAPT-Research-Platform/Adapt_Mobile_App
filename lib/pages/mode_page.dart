import 'package:adapt/widgets/main_title.dart';
import 'package:adapt/widgets/sub_title.dart';
import 'package:flutter/material.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';

import '../models/mode.dart';
import '../services/firebase_mode_service.dart';
import '../utils/app_colors.dart';
import '../utils/app_font_sizes.dart';
import '../widgets/feeling_chart.dart';
import '../widgets/motivation_chart.dart';
import '../widgets/task_button.dart';

class ModePage extends StatefulWidget {
  const ModePage({super.key});

  @override
  _ModePageState createState() => _ModePageState();
}

class _ModePageState extends State<ModePage> {
  final ScrollController _scrollController = ScrollController();
  final FirebaseModeService _firebaseModeService = FirebaseModeService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: const MainTitle(title: 'Mood'),
        body: FutureBuilder<List<Mode>>(
            future: _firebaseModeService.fetchModeList(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: AppColors.darkYellow));
              } else if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text("Error loading mode tracking data"));
              }

              final modeData = snapshot.data!;

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Column(
                  children: [
                    TaskButton(
                        text: '2024 November',
                        onPressed: () {
                          showMonthPicker(
                            context: context,
                            initialDate: DateTime.now(),
                          ).then((date) {
                            if (date != null) {
                              print(date);
                            }
                          });
                        }
                    ),

                    const SubTitle(text: 'Feeling'),
                    Expanded(
                      child: FeelingChart(modeData: modeData),
                    ),
                    const Divider(
                      color: AppColors.lightGrey,
                      // Customize the color as needed
                      thickness: 2.5, // Customize the thickness as needed
                    ),
                    const SubTitle(text: 'Motivation'),
                    Expanded(
                      child: MotivationChart(modeData: modeData),
                    ),
                  ],
                ),
              );
            }));
  }
}