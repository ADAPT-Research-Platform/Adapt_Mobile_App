import 'package:adapt/utils/app_colors.dart';
import 'package:flutter/material.dart';

import '../models/section.dart';
import '../utils/app_font_sizes.dart';

class SectionCard extends StatelessWidget {
  final Section section;
  final VoidCallback onPressed;

  const SectionCard({
    super.key,
    required this.section,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
        decoration: BoxDecoration(
          color: section.isExercise ? AppColors.paleYellow : AppColors.darkWhite,
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
                  section.sectionName,
                  style: const TextStyle(
                    color: AppColors.fontColor, // Static text color
                    fontSize: AppFontSizes.small,
                    fontWeight: FontWeight.bold, // Static font size
                  ),
                ),
                Text(
                  "${DateTime.now().difference(section.timeStamp).inDays} Days Ago",
                  style: const TextStyle(
                    fontSize: AppFontSizes.mini,
                    color: AppColors.fontColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            Text(
              section.title,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.fontColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
