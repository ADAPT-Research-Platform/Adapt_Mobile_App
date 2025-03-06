import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:logging/logging.dart';

import '../models/answer.dart';
import '../utils/app_font_sizes.dart';

class AnswerCard extends StatefulWidget {
  final Answer answer;

  const AnswerCard({super.key, required this.answer});

  @override
  _AnswerCardState createState() => _AnswerCardState();
}

class _AnswerCardState extends State<AnswerCard> {
  final log = Logger('AnswerCard');

  @override
  Widget build(BuildContext context) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  'Module ${widget.answer.moduleId}: Chapter ${widget.answer.chapterIndex}',
                  style: const TextStyle(
                    fontSize: AppFontSizes.small,
                    fontWeight: FontWeight.bold, // Static font size
                  ),
                ),
                const Spacer(),
                Text(
                  DateFormat('dd.MM.yyyy HH:mm:ss').format(widget.answer.timeStamp),
                  style: const TextStyle(
                    fontSize: AppFontSizes.mini, // Static font size
                  ),
                ),
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: widget.answer.text.entries
                  .where((entry) => entry.value.trim().isNotEmpty) // Filter non-empty values
                  .map((entry) {
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${entry.key}:', // Question key
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 4), // Small spacing between key and value
                      Expanded(
                        child: Text(
                          entry.value, // Answer text
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          )
        ],
      );
  }
}
