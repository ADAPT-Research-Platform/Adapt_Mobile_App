import 'package:flutter/material.dart';

import '../models/chapter.dart';
import '../services/localization_service.dart';
import '../utils/time_formatter.dart';
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
            Row(
              children: [
                Expanded(
                  flex: 1,
                  child: Text(
                    chapter.isExercise
                        ? '${LocalizationService().get('Chapter')} ${chapter.chapterIndex}: ${LocalizationService().get('Exercise')}'
                        : '${LocalizationService().get('Chapter')} ${chapter.chapterIndex}',
                    style: const TextStyle(
                      fontSize: AppFontSizes.small,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 16), // This SizedBox provides a guaranteed minimum space between the two texts.
                Expanded(
                  flex: 1,
                  child: Text(
                    formatTimeAgo(chapter.timeStamp),
                    textAlign: TextAlign.end,
                    style: const TextStyle(
                      fontSize: AppFontSizes.mini,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              chapter.title,
              style: const TextStyle(
                fontSize: AppFontSizes.mini,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Wrap(
                    alignment: WrapAlignment.end,
                    spacing: 12.0,
                    runSpacing: 4.0,

                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.access_time_filled_rounded,
                            color: Theme.of(context).primaryColorDark,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            "${chapter.progress.round()}% ${LocalizationService().get('Progress')}",
                            style: const TextStyle(
                              fontSize: AppFontSizes.mini,
                            ),
                          ),
                        ],
                      ),

                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.list_alt_rounded,
                            color: Theme.of(context).primaryColorDark,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            "${chapter.numOfComments} ${LocalizationService().get('Comments')}",
                            style: const TextStyle(
                              fontSize: AppFontSizes.mini,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
