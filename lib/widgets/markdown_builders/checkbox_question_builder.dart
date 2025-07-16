import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import 'package:logging/logging.dart';
import 'package:markdown/markdown.dart' as md;
import 'dart:convert';

import '../../models/checkbox_question.dart';


class CheckboxQuestionViewerBuilder extends MarkdownElementBuilder {
  final log = Logger('CheckboxQuestionViewerBuilder');

  // These maps now store CheckboxQuestionData objects directly
  final Map<String, CheckboxQuestion> _questionDataMap = {};
  final Map<String, List<int>> _userSelectionsMap; // Stores user's selected indices
  final Function(String, int, bool) onCheckboxChanged; // Callback for state updates

  CheckboxQuestionViewerBuilder(
      this._userSelectionsMap,
      this.onCheckboxChanged,
      ) {
    // You might want to clear _questionDataMap on load if new content
    // is always replacing old. Or ensure IDs are unique.
  }

  @override
  Widget? visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    if (element.tag == 'checkbox') { // Changed tag to 'checkbox'
      try {
        final jsonContent = element.children!.first.textContent;
        final Map<String, dynamic> rawJson = jsonDecode(jsonContent);

        final CheckboxQuestion questionData = CheckboxQuestion.fromJson(rawJson);

        // Store the parsed question data for later reference (e.g., for scoring)
        _questionDataMap[questionData.id] = questionData;

        // Initialize user selections for this question if not already present
        // When loading, these should be empty, so the user starts fresh.
        if (!_userSelectionsMap.containsKey(questionData.id)) {
          _userSelectionsMap[questionData.id] = [];
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text(
                questionData.question,
                style: const TextStyle(
                  fontSize: 16, // Adjust as needed
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ...List.generate(questionData.answers.length, (index) {
              final isSelected = _userSelectionsMap[questionData.id]!.contains(index);

              // Use RadioListTile if Multiple is false, otherwise CheckboxListTile
              if (!questionData.multiple) {
                return RadioListTile<int>(
                  title: Text(questionData.answers[index]),
                  value: index,
                  groupValue: isSelected ? index : null, // If selected, group value is this index
                  onChanged: (int? newValue) {
                    // When radio button is selected, clear previous selections and add new one
                    onCheckboxChanged(questionData.id, newValue!, true);
                  },
                  dense: true,
                );
              } else {
                return CheckboxListTile(
                  title: Text(questionData.answers[index]),
                  value: isSelected,
                  onChanged: (bool? newValue) {
                    onCheckboxChanged(questionData.id, index, newValue ?? false);
                  },
                  dense: true,
                );
              }
            }),
            const SizedBox(height: 16),
          ],
        );
      } catch (e) {
        log.severe("Error parsing Checkbox Question JSON: $e");
        return Text('Error loading question: ${e.toString()}'); // Provide feedback
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
  // Regex to match `[checkbox]{` followed by a multi-line JSON block.
  // It's crucial to correctly capture the JSON block.
  // This regex looks for `[checkbox]{`, then non-greedy capture of any characters,
  // then `}`, and then ensures there's a line break or end of file.
  // The `(?:.|\n)` part allows it to match across multiple lines.
  // We will then parse this captured content as JSON.
  @override
  RegExp get pattern => RegExp(
    r'^\[checkbox\](\{[\s\S]+?\})\s*$',
    multiLine: true,
  );

  @override
  md.Node? parse(md.BlockParser parser) {
    final match = pattern.firstMatch(parser.current.content);

    if (match != null) {
      final String fullMatch = match.group(0)!; // The entire matched block (e.g., [checkbox]{...})
      final String jsonContent = match.group(1)!; // The content inside the curly braces

      // We need to consume all lines that are part of this JSON block.
      // A simple `parser.advance()` might not be enough if the JSON spans multiple lines.
      // However, the `pattern` for BlockSyntax already consumes the entire matched block.
      // So, `parser.advance()` effectively consumes the lines making up the block.
      parser.advance(); // Consume the entire matched block

      final md.Element el = md.Element('p', [
        // Create a custom element to hold the JSON string
        md.Element('checkbox', [
          md.UnparsedContent(jsonContent),
        ]),
      ]);
      return el;
    }
    log.warning("Checkbox BlockSyntax: Pattern not matched for line: '${parser.current.content}'");
    return null;
  }
}