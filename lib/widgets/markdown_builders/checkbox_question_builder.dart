import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import 'package:logging/logging.dart';
import 'package:markdown/markdown.dart' as md;
import 'dart:convert';

import '../../models/checkbox_question.dart';
import '../../utils/app_font_sizes.dart';


class CheckboxQuestionViewerBuilder extends MarkdownElementBuilder {
  final log = Logger('CheckboxQuestionViewerBuilder');

  // These maps now store CheckboxQuestionData objects directly
  final Map<String, CheckboxQuestion> _questionDataMap = {};
  final ValueNotifier<Map<String, List<int>>>
      _userSelectionsNotifier; // Stores user's selected indices
  final Function(String, int, bool) onCheckboxChanged; // Callback for state updates

  CheckboxQuestionViewerBuilder(
    this._userSelectionsNotifier,
    this.onCheckboxChanged,
  ) {
    // You might want to clear _questionDataMap on load if new content
    // is always replacing old. Or ensure IDs are unique.
  }

  @override
  Widget? visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    if (element.tag == 'checkbox') {
      // Changed tag to 'checkbox'
      try {
        final jsonContent = element.children!.first.textContent;
        final Map<String, dynamic> rawJson = jsonDecode(jsonContent);

        final CheckboxQuestion questionData = CheckboxQuestion.fromJson(rawJson);

        // Store the parsed question data for later reference (e.g., for scoring)
        _questionDataMap[questionData.id] = questionData;

        // Initialize user selections for this question if not already present
        // When loading, these should be empty, so the user starts fresh.
        if (!_userSelectionsNotifier.value.containsKey(questionData.id)) {
          _userSelectionsNotifier.value[questionData.id] = [];
        }

        return ValueListenableBuilder<Map<String, List<int>>>(
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
                    Column(
                      children: List.generate(questionData.answers.length,
                          (index) {
                        final isSelected =
                            userSelections[questionData.id]!.contains(index);

                        final WidgetStateProperty<Color?> fillColorResolver =
                            WidgetStateProperty.resolveWith((states) {
                          if (states.contains(WidgetState.selected)) {
                            return const Color(0xFFFEC63D);
                          }
                          return null;
                        });

                        final CheckBoxAnswer answer = questionData.answers[index];

                        if (!questionData.multiple) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 0.0),
                            child: RadioListTile<int>(
                              title: Text(answer.text),
                              value: index,
                              groupValue: userSelections[questionData.id]?.isNotEmpty == true
                                  ? userSelections[questionData.id]![0]
                                  : null,
                              onChanged: (int? newValue) {
                                if (newValue != null) {
                                  onCheckboxChanged(questionData.id, newValue, true);
                                }
                              },
                              dense: true,
                              controlAffinity: ListTileControlAffinity.leading,
                              fillColor: fillColorResolver,
                            ),
                          );
                        } else {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 0.0),
                            child: CheckboxListTile(
                              title: Text(answer.text),
                              value: isSelected,
                              onChanged: (bool? newValue) {
                                onCheckboxChanged(questionData.id, index, newValue ?? false);
                              },
                              dense: true,
                              controlAffinity: ListTileControlAffinity.leading,
                              fillColor: fillColorResolver,
                            ),
                          );
                        }
                      }),
                    ),
                  ],
                ),
              );
            });
      } catch (e) {
        log.severe("Error parsing Checkbox Question JSON: $e");
        return Text(
            'Error loading question: ${e.toString()}'); // Provide feedback
      }
    }
    return null;
  }

  // Getter to access the parsed question data for scoring
  Map<String, CheckboxQuestion> get questionDataMap => _questionDataMap;
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