import 'package:flutter/material.dart';

import '../models/chapter.dart';
import '../services/localization_service.dart';
import '../utils/app_font_sizes.dart';

class ChapterCard extends StatelessWidget {
  final Chapter chapter;
  final VoidCallback onPressed;

  const ChapterCard({
    super.key,
    required this.chapter,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
        decoration: BoxDecoration(
          color: chapter.isExercise ? Theme.of(context).highlightColor : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Theme.of(context).primaryColorDark, // Border color
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
                  chapter.isExercise
                  ? '${LocalizationService().get('Chapter')} ${chapter.chapterIndex}: ${LocalizationService().get('Exercise')}'
                  : '${LocalizationService().get('Chapter')} ${chapter.chapterIndex}',
                  style: const TextStyle(
                    fontSize: AppFontSizes.small,
                    fontWeight: FontWeight.bold, // Static font size
                  ),
                ),
                Text(
                  timeAgo(chapter.timeStamp),
                  style: const TextStyle(
                    fontSize: AppFontSizes.mini,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 5),
            Text(
              chapter.title,
              style: const TextStyle(
                fontSize: AppFontSizes.mini,
              ),
            ),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Row(
                  children: [
                    Icon(Icons.access_time_filled_rounded, color: Theme.of(context).primaryColorDark),
                    const SizedBox(width: 4),
                    Text("${chapter.progress.round()}% ${LocalizationService().get('Progress')}",
                      style: const TextStyle(
                        fontSize: AppFontSizes.mini,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 8),
                Row(
                  children: [
                    Icon(Icons.list_alt_rounded, color: Theme.of(context).primaryColorDark),
                    const SizedBox(width: 4),
                    Text("${chapter.numOfComments} ${LocalizationService().get('Comments')}",
                      style: const TextStyle(
                        fontSize: AppFontSizes.mini,
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

  String timeAgo(DateTime timestamp) {
    final duration = DateTime.now().difference(timestamp);

    if (duration.inDays >= 1) {
      return "${duration.inDays} Days Ago";
    } else if (duration.inHours >= 1) {
      return "${duration.inHours} Hrs Ago";
    } else if (duration.inMinutes >= 1) {
      return "${duration.inMinutes} Min Ago";
    } else {
      return "${duration.inSeconds} Sec Ago";
    }
  }
}
