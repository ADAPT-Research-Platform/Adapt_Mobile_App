import 'package:adapt/utils/app_colors.dart';
import 'package:flutter/material.dart';

import '../utils/app_font_sizes.dart';

class ExerciseCard extends StatelessWidget {
  final String title;
  final String period;
  final int answers;
  final double progress;
  final VoidCallback onPressed;

  const ExerciseCard({
    super.key,
    required this.title,
    required this.period,
    required this.answers,
    required this.progress,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
        decoration: BoxDecoration(
          color: AppColors.darkWhite,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: AppColors.darkYellow, // Border color
            width: 2.2,          // Border width
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title and Period Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.fontColor, // Static text color
                    fontSize: AppFontSizes.small,
                    fontWeight: FontWeight.bold, // Static font size
                  ),
                ),
                Text(
                  period,
                  style: const TextStyle(
                    fontSize: AppFontSizes.mini,
                    color: AppColors.fontColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Progress and Answers Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.electric_meter, color: AppColors.darkYellow),
                    const SizedBox(width: 4),
                    Text(
                      "${(progress * 100).toInt()}% Progress",
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.fontColor,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Icon(Icons.comment, color: AppColors.primaryYellow),
                    const SizedBox(width: 4),
                    Text(
                      "$answers Answers",
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.fontColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
