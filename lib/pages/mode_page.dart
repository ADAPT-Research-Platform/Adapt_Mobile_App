import 'package:adapt/widgets/app_title_bar.dart';
import 'package:flutter/material.dart';

import '../models/mode.dart';
import '../utils/app_colors.dart';
import '../utils/app_font_sizes.dart';
import '../widgets/feeling_chart.dart';
import '../widgets/motivation_chart.dart';

class ModePage extends StatelessWidget {
  const ModePage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Mode> modeData = [
      Mode(
        modeId: '6',
        timeStamp: DateTime.now().subtract(Duration(days: 6)),
        feeling: 4,
        motivation: 8.5,
      ),
      Mode(
        modeId: '5',
        timeStamp: DateTime.now().subtract(Duration(days: 5)),
        feeling: 4,
        motivation: 6.5,
      ),
      Mode(
        modeId: '4',
        timeStamp: DateTime.now().subtract(Duration(days: 4)),
        feeling: 3,
        motivation: 4.5,
      ),
      Mode(
        modeId: '1',
        timeStamp: DateTime.now().subtract(Duration(days: 3)),
        feeling: 2,
        motivation: 5.0,
      ),
      Mode(
        modeId: '2',
        timeStamp: DateTime.now().subtract(Duration(days: 2)),
        feeling: 3,
        motivation: 6.5,
      ),
      Mode(
        modeId: '3',
        timeStamp: DateTime.now().subtract(Duration(days: 1)),
        feeling: 1,
        motivation: 7.5,
      ),
    ];

    return Scaffold(
        appBar: AppTitleBar(title: 'Mode'),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Column(
            children: [
              const Center(
                child: Text(
                  'Feeling',
                  style: TextStyle(
                    color: AppColors.darkYellow, // Static text color
                    fontSize: AppFontSizes.medium, // Static font size
                    fontWeight: FontWeight.bold, // Static font weight
                  ),
                ),
              ),
              Expanded(
                child: FeelingChart(modeData: modeData),
              ),
              const Divider(
                color: AppColors.lightGrey, // Customize the color as needed
                thickness: 2.5, // Customize the thickness as needed
              ),
              const Center(
                child: Text(
                  'Motivation',
                  style: TextStyle(
                    color: AppColors.darkYellow, // Static text color
                    fontSize: AppFontSizes.medium, // Static font size
                    fontWeight: FontWeight.bold, // Static font weight
                  ),
                ),
              ),

              Expanded(
                child: MotivationChart(modeData: modeData),
              ),
            ],
          ),
        ));
  }
}