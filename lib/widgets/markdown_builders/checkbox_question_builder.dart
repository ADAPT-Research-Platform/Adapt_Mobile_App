import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:logging/logging.dart';
import 'package:markdown/markdown.dart' as md;

import '../../models/checkbox_question.dart';
import '../../utils/app_font_sizes.dart';
import '../../utils/score_store.dart';

class CheckboxQuestionViewerBuilder extends MarkdownElementBuilder {
  final log = Logger('CleanCheckboxBuilder');

  final String chapterKey;
  final Map<String, Map<int, int>> savedAnswers;

  CheckboxQuestionViewerBuilder(
      this.chapterKey,
      this.savedAnswers,
      );

  @override
  Widget? visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    if (element.tag == 'checkbox') {
      // Changed tag to 'checkbox'
      try {
        final jsonContent = element.children!.first.textContent;
        final questionData = CheckboxQuestion.fromJson(jsonDecode(jsonContent));

        // Restore saved answers from device storage if available
        if (savedAnswers.containsKey(questionData.id)) {
          questionData.selectedAnswers = savedAnswers[questionData.id]!.keys.toSet();
        }

        // Return a self-contained stateful widget for this card only
        return _QuestionCardWidget(questionData: questionData, chapterKey: chapterKey);
      } catch (e) {
        log.severe("Error parsing Checkbox Question JSON: $e");
        return Text('Error loading question: ${e.toString()}');
      }
    }
    return null;
  }
}

class _QuestionCardWidget extends StatefulWidget {
  final CheckboxQuestion questionData;
  final String chapterKey;

  const _QuestionCardWidget({
    required this.questionData,
    required this.chapterKey,
  });

  @override
  State<_QuestionCardWidget> createState() => _QuestionCardWidgetState();
}

class _QuestionCardWidgetState extends State<_QuestionCardWidget> {
  final ScoreStore _scoreStore = ScoreStore();

  Future<void> _updateAnswerAndPointsInStore(int index, int points, bool isChecked) async {
    // 1. Fetch current stored map
    Map<String, Map<int, int>> currentAnswers = await _scoreStore.getChapterAnswers(widget.chapterKey);

    // 2. Get or initialize the inner map for this specific question
    Map<int, int> questionSelections = currentAnswers[widget.questionData.id] ?? {};

    if (widget.questionData.multiple) {
      if (isChecked) {
        questionSelections[index] = points; // Store index -> points
      } else {
        questionSelections.remove(index);
      }
    } else {
      questionSelections.clear();
      if (isChecked) {
        questionSelections[index] = points;
      }
    }

    currentAnswers[widget.questionData.id] = questionSelections;

    // 3. Save back instantly
    await _scoreStore.setChapterAnswers(widget.chapterKey, currentAnswers);
  }

  @override
  Widget build(BuildContext context) {
    final q = widget.questionData;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      padding: const EdgeInsets.fromLTRB(12.0, 12.0, 12.0, 0.0),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).primaryColorLight,
          width: 2.2,
        ),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            q.question,
            style: const TextStyle(
              fontSize: AppFontSizes.small,
              fontWeight: FontWeight.bold,
            ),
          ),
          ...List.generate(q.answers.length, (index) {
            final answer = q.answers[index];
            final isSelected = q.selectedAnswers.contains(index);
            final WidgetStateProperty<Color?> fillColorResolver = WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return Theme.of(context).primaryColorLight;
              }
              return null;
            });

            if (q.multiple) {
              return CheckboxListTile(
                title: Text(answer.text),
                value: isSelected,
                dense: true,
                controlAffinity: ListTileControlAffinity.leading,
                fillColor: fillColorResolver,
                onChanged: (bool? val) async {
                  bool isChecked = val ?? false;
                  int points = answer.points; // Points from your CheckBoxAnswer model

                  setState(() {
                    q.toggleSelection(index, isChecked);
                  });

                  await _updateAnswerAndPointsInStore(index, points, isChecked);
                },
              );
            } else {
              return RadioListTile<int>(
                title: Text(answer.text),
                value: index,
                groupValue: q.selectedAnswers.isEmpty ? null : q.selectedAnswers.first,
                dense: true,
                controlAffinity: ListTileControlAffinity.leading,
                fillColor: fillColorResolver,
                onChanged: (int? val) async {
                  if (val != null) {
                    bool isCurrentlySelected = q.selectedAnswers.contains(val);
                    bool willBeChecked = !isCurrentlySelected;
                    int points = answer.points;

                    setState(() {
                      q.toggleSelection(val, willBeChecked);
                    });

                    await _updateAnswerAndPointsInStore(val, points, willBeChecked);
                  }
                },
              );
            }
          }),
          Text(
            "Score: ${q.score}",
            style: const TextStyle(
              fontSize: AppFontSizes.mini,
            ),
          ),
        ],
      ),
    );
  }
}

class CheckboxQuestionSyntax extends md.BlockSyntax {
  final log = Logger('CheckboxQuestionSyntax');

  CheckboxQuestionSyntax();

  @override
  RegExp get pattern => RegExp(r'^\[checkbox\]');

  @override
  md.Node? parse(md.BlockParser parser) {
    if (!parser.current.content.trim().startsWith('[checkbox]')) {
      return null;
    }

    // Consume the [checkbox] line and remove the tag
    var firstLine = parser.current.content;
    parser.advance();

    // Start buffer with JSON start
    final buffer = StringBuffer();
    // Remove "[checkbox]" and any whitespace before JSON start
    final startJson = firstLine.replaceFirst('[checkbox]', '').trim();
    buffer.write(startJson);

    // Brace count to ensure we read full JSON object (handles nested braces)
    int braceCount = 0;
    for (var char in startJson.split('')) {
      if (char == '{') {
        braceCount++;
      } else if (char == '}') braceCount--;
    }

    // Keep reading lines until braceCount == 0 (JSON object complete)
    while (!parser.isDone && braceCount > 0) {
      final line = parser.current.content;
      buffer.writeln(line);

      for (var char in line.split('')) {
        if (char == '{') {
          braceCount++;
        } else if (char == '}') braceCount--;
      }
      parser.advance();
    }

    final jsonContent = buffer.toString().trim();

    return md.Element('p', [
      md.Element('checkbox', [
        md.UnparsedContent(jsonContent),
      ])
    ]);
  }
}