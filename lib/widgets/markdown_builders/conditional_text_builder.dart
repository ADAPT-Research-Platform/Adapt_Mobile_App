import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:markdown/markdown.dart' as md;

import '../../utils/score_store.dart';

class ConditionalTextBuilder extends MarkdownElementBuilder {
  final ScoreStore scoreStore;

  ConditionalTextBuilder(this.scoreStore);

  @override
  Widget? visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    // If it's an error element, just hide it.
    if (element.attributes['is_error'] == 'true') {
      return const SizedBox.shrink();
    }

    final rawJson = element.attributes['json'] ?? '{}';
    final jsonData = json.decode(rawJson);
    final key = jsonData['key'] as String?;
    final condition = jsonData['condition'] as String?;

    if (key == null || condition == null) return const SizedBox.shrink();

    if (evaluateScoreCondition(
        key: key, condition: condition, scoreStore: scoreStore)) {
      return Wrap(children: [Text(element.textContent)]);
    } else {
      return const SizedBox.shrink();
    }
  }

  bool evaluateScoreCondition({
    required String key,
    required String condition,
    required ScoreStore scoreStore,
  }) {
    int? score = scoreStore.getScore(key);
    if (kDebugMode) {
      print('ConditionalText: Key: $key, Condition: $condition, Score: $score');
    }

    if (score == null) return false;

    // Split multiple conditions by comma
    final conditions = condition.split(',').map((c) => c.trim());

    for (final cond in conditions) {
      final match = RegExp(r'(==|>=|<=|>|<)\s*(\d+)').firstMatch(cond);
      if (match == null) {
        print('ConditionalText: Invalid condition format: "$cond"');
        return false; // if any condition is invalid, we fail the block
      }

      final operator = match.group(1)!;
      final value = int.parse(match.group(2)!);

      bool isValid;
      switch (operator) {
        case '==': isValid = score == value; break;
        case '>=': isValid = score >= value; break;
        case '<=': isValid = score <= value; break;
        case '>':  isValid = score > value; break;
        case '<':  isValid = score < value; break;
        default:   isValid = false; break;
      }

      if (!isValid) return false; // all conditions must be true
    }

    return true; // all conditions passed
  }
}

class ConditionalTextSyntax extends md.BlockSyntax {
  @override
  bool canParse(md.BlockParser parser) {
    final line = parser.current.content;
    print('ConditionalTextSyntax: canParse called for: "$line"');
    // Check if line starts with [if] optionally followed by {
    return RegExp(r'^\[if\]\s*\{?$').hasMatch(line);
  }


  @override
  md.Node? parse(md.BlockParser parser) {
    print('ConditionalTextSyntax: parse method called.'); // Debug print
    // Consume the "[if]" line.
    parser.advance();

    String? jsonConfigLine;
    final List<String> rawBlockLines = [];
    bool foundEndif = false;
    String? errorMessage;

    // First, consume all lines until [endif] or end of document
    while (!parser.isDone) {
      final currentLine = parser.current;
      final trimmedContent = currentLine.content.trim();

      if (trimmedContent == '[endif]') {
        foundEndif = true;
        parser.advance(); // Consume the [endif] line
        break;
      }
      rawBlockLines.add(currentLine.content); // Store original content
      parser.advance();
    }

    if (!foundEndif) {
      errorMessage = 'Missing [endif]';
    }

    // Now process the collected lines to find JSON and content
    int jsonLineIndex = -1;
    if (errorMessage == null) { // Only proceed if no missing [endif] error
      for (int i = 0; i < rawBlockLines.length; i++) {
        final trimmedLine = rawBlockLines[i].trim();
        if (trimmedLine.isEmpty) {
          continue; // Skip empty lines
        }
        if (trimmedLine.startsWith('{') && trimmedLine.endsWith('}')) {
          jsonConfigLine = trimmedLine;
          jsonLineIndex = i;
          break;
        } else {
          // If it's not empty and not JSON, it's unexpected content before JSON
          errorMessage = 'Unexpected content before JSON: "$trimmedLine"';
          break;
        }
      }
    }

    if (errorMessage == null && jsonConfigLine == null) {
      errorMessage = 'Missing JSON configuration';
    }

    Map<String, dynamic> jsonData = {}; // Default empty JSON data
    if (errorMessage == null) { // Only try to decode if no previous errors
      try {
        jsonData = json.decode(jsonConfigLine!);
        print('ConditionalTextSyntax: JSON parsed successfully: $jsonData'); // Debug print
      } catch (e) {
        errorMessage = 'Invalid JSON: $jsonConfigLine - Error: $e';
        print('ConditionalTextSyntax: JSON parsing failed: $errorMessage'); // Debug print
      }
    }

    final innerContent = (jsonLineIndex != -1 && jsonLineIndex + 1 < rawBlockLines.length)
        ? rawBlockLines.sublist(jsonLineIndex + 1).join('\n')
        : '';

    List<md.Node> children = [];
    if (innerContent.isNotEmpty) {
      // Parse the inner content as Markdown to get a list of nodes
      final document = md.Document(
        extensionSet: md.ExtensionSet.commonMark,
      );
      children = document.parseLines(innerContent.split('\n'));
    }

    final element = md.Element('if', children); // Pass children directly

    if (errorMessage != null) {
      print('ConditionalTextSyntax: Returning error element: $errorMessage'); // Debug print
      element.attributes['is_error'] = 'true';
      element.attributes['error_message'] = errorMessage;
      // Children are already set in the constructor, no need to clear
    } else {
      element.attributes['json'] = json.encode(jsonData);
    }

    return md.Element('p', [
      md.Element('if', [md.Text(innerContent)])
        ..attributes['json'] = jsonEncode(jsonData)
    ]);

  }

  @override
  RegExp get pattern => RegExp(
    r'^\[if\]\s*\{[\s\S]*?\}\s*[\s\S]*?\[endif\]$',
    multiLine: true,
  );
}