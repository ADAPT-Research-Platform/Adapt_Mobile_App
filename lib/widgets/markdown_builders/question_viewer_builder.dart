import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:logging/logging.dart';
import 'package:markdown/markdown.dart' as md;

import '../../utils/app_colors.dart';
import '../../utils/app_font_sizes.dart';

class QuestionViewerBuilder extends MarkdownElementBuilder {
  final log = Logger('QuestionViewerBuilder');

  final Map<String, String> questions;
  final Map<String, String> currentAnswers;
  final Map<String, TextEditingController> controllers;

  QuestionViewerBuilder(
      this.questions,
      this.currentAnswers,
      this.controllers
    );

  final _jsonPattern = RegExp(r'^\{.*\}$', multiLine: true, dotAll: true);

  @override
  Widget? visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    final content = element.children?.first.textContent;
    if (_jsonPattern.hasMatch(content!)) {
      try {
        final jsonMap = jsonDecode(content) as Map<String, dynamic>;

        if (jsonMap.isNotEmpty) {
          String questionKey = jsonMap.keys.first; // Extract the single key
          String questionValue = jsonMap.values.first; // Extract the single value

          // Add to questions map
          questions[questionKey] = questionValue;

          // Create or fetch a controller and pre-fill with current answers if available
          controllers[questionKey] = controllers[questionKey] ?? TextEditingController(text: currentAnswers[questionKey]);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(questions[questionKey] ?? "",
                style: const TextStyle(
                  color: AppColors.fontColor,
                  fontSize: AppFontSizes.small,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: controllers[questionKey],
                maxLines: null, // Makes the TextField multiline
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Write your answer here',
                ),
              ),
              const SizedBox(height: 16),
            ],
          );
        }
      } catch (e) {
        log.severe("Error parsing JSON: $e");
      }
    }else{
      log.severe("Question JSON Content Not Valid: $content");
    }

    // Return the default text if it's not JSON
    return null;
  }
}

class QuestionSyntax extends md.BlockSyntax {
  final log = Logger('QuestionSyntax');
  QuestionSyntax();

  @override
  RegExp get pattern => RegExp(r'^\[question\](\{".+?":\s*".*?"\})$', dotAll: true);

  @override
  md.Node? parse(md.BlockParser parser) {
    final match = pattern.firstMatch(parser.current.content);
    if (match != null) {
      final String jsonContent = match.group(1).toString();
      parser.advance();

      final contents = md.UnparsedContent(jsonContent);

      final md.Element el = md.Element('p', [
        md.Element('question', [contents]),
      ]);

      return el;
    }else{
      log.warning("Question Pattern Not Matched: $match");
    }
    return null;
  }
}

