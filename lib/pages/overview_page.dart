import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../utils/app_colors.dart';
import '../widgets/app_title_bar.dart';
import '../widgets/hexagon_grid.dart';
import '../utils/app_font_sizes.dart';

class OverviewPage extends StatelessWidget {
  const OverviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppTitleBar(title: 'Overview'),
        body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0),
            child: ListView(children: [
              const Center(
                child: Text(
                  'Progress',
                  style: TextStyle(
                    color: AppColors.darkYellow, // Static text color
                    fontSize: AppFontSizes.medium, // Static font size
                    fontWeight: FontWeight.bold, // Static font weight
                  ),
                ),
              ),
              Center(
                  // Center the content
                  child: Container(
                height: 300,
                child: HexagonGrid(
                  rows: 7,
                  cols: 2,
                  size: 90,
                  fillColor: AppColors.primaryYellow,
                  strokeColor: AppColors.white,
                  strokeWidth: 6,
                  icon: Icons.play_arrow_rounded,
                  iconColor: AppColors.darkYellow,
                ),
              )),
              ElevatedButton(
                onPressed: () {},
                child: Text(
                  'Continue',
                  style: const TextStyle(
                    fontSize: AppFontSizes.small,
                    fontWeight: FontWeight.bold, // Static font size
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  foregroundColor: AppColors.white,
                  backgroundColor: AppColors.primaryYellow,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6.0),
                  ),
                  minimumSize: Size(double.infinity, 50),
                ),
              ),
              Container(
                  padding: const EdgeInsets.only(bottom: 10),
                  decoration: const BoxDecoration(
                      color: Colors.transparent,
                      border: Border(
                          bottom: BorderSide(
                              color: AppColors.lightGrey, width: 2.5)))),
              Center(
                child: Text(
                  'Everyday Questions',
                  style: const TextStyle(
                    color: AppColors.darkYellow, // Static text color
                    fontSize: AppFontSizes.medium, // Static font size
                    fontWeight: FontWeight.bold, // Static font weight
                  ),
                ),
              ),
            ])));
  }
}
