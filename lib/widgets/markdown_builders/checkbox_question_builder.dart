import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:logging/logging.dart';
import 'package:markdown/markdown.dart' as md;

import '../../models/checkbox_answer.dart';
import '../../models/checkbox_question.dart';
import '../../utils/app_font_sizes.dart';

class CheckboxQuestionViewerBuilder extends MarkdownElementBuilder {
  final log = Logger('CheckboxQuestionViewerBuilder');

  final ValueNotifier<Map<String, CheckboxQuestion>> _userSelectionsNotifier;
  final Map<String, Set<int>> previousAnswers;
  final Function(String, int, bool) onCheckboxChanged;

  CheckboxQuestionViewerBuilder(
    this._userSelectionsNotifier,
    this.previousAnswers,
    this.onCheckboxChanged
  );

  @override
  Widget? visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    if (element.tag == 'checkbox') {
      // Changed tag to 'checkbox'
      try {
        final jsonContent = element.children!.first.textContent;
        final Map<String, dynamic> rawJson = jsonDecode(jsonContent);

        final CheckboxQuestion questionData = CheckboxQuestion.fromJson(rawJson);

        // Initialize user selections for this question if not already present
        // When loading, these should be empty, so the user starts fresh.
        if (!_userSelectionsNotifier.value.containsKey(questionData.id)) {
          if(previousAnswers.containsKey(questionData.id)){
            questionData.selectedAnswers = previousAnswers[questionData.id]!;
          }

          _userSelectionsNotifier.value[questionData.id] = questionData;
        }

        return ValueListenableBuilder<Map<String, CheckboxQuestion>>(
            valueListenable: _userSelectionsNotifier,
            builder: (context, userSelections, child) {
              return Container(
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0EBEB),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: const Color(0xFFA08030),
                    width: 2.2,
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(12.0, 12.0, 12.0, 0.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      questionData.question,
                      style: const TextStyle(
                        fontSize: AppFontSizes.small,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (questionData.multiple)
                      Column(
                        children: List.generate(questionData.answers.length, (index) {
                          final isSelected = userSelections[questionData.id]!.selectedAnswers.contains(index);
                          final WidgetStateProperty<Color?> fillColorResolver =
                          WidgetStateProperty.resolveWith((states) {
                            if (states.contains(WidgetState.selected)) {
                              return const Color(0xFFFEC63D);
                            }
                            return null;
                          });
                          final CheckBoxAnswer answer = questionData.answers[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 0.0),
                            child: CheckboxListTile(
                              title: Text(answer.text),
                              value: isSelected,
                              onChanged: (bool? newValue) {
                                onCheckboxChanged(questionData.id, index, newValue!);
                              },
                              dense: true,
                              controlAffinity: ListTileControlAffinity.leading,
                              fillColor: fillColorResolver,
                            ),
                          );
                        }),
                      )
                    else
                      RadioGroup<int>(
                        groupValue: userSelections[questionData.id]!.selectedAnswers.isEmpty
                            ? null : userSelections[questionData.id]!.selectedAnswers.first,
                        onChanged: (int? newValue) {
                          if (newValue != null) {
                            onCheckboxChanged(questionData.id, newValue, true);
                          }
                        },
                        child: Column(
                          children: List.generate(userSelections[questionData.id]!.answers.length, (index) {
                            final WidgetStateProperty<Color?> fillColorResolver =
                            WidgetStateProperty.resolveWith((states) {
                              if (states.contains(WidgetState.selected)) {
                                return const Color(0xFFFEC63D);
                              }
                              return null;
                            });
                            final CheckBoxAnswer answer = questionData.answers[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 0.0),
                              child: RadioListTile<int>(
                                title: Text(answer.text),
                                value: index,
                                dense: true,
                                controlAffinity: ListTileControlAffinity.leading,
                                fillColor: fillColorResolver,
                              ),
                            );
                          }),
                        ),
                      )
                    ,
                    Text(
                      "Score: ${questionData.score}",
                      style: const TextStyle(
                        fontSize: AppFontSizes.mini,
                      ),
                    ),
                  ],
                ),
              );
            });
      } catch (e) {
        log.severe("Error parsing Checkbox Question JSON: $e");
        return Text('Error loading question: ${e.toString()}');
      }
    }
    return null;
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