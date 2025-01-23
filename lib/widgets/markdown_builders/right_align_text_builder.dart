import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:markdown/markdown.dart' as markdown;

class RightAlignBuilder extends MarkdownElementBuilder {
  @override
  Widget visitElementAfter(markdown.Element element, TextStyle? preferredStyle) {
    return SizedBox(
      width: double.infinity,
      child: Align(
        alignment: Alignment.centerRight,
        child: Text(
          element.textContent,
          style: preferredStyle, // Apply the style passed from Markdown
        ),
      ),
    );
  }
}

class RightAlignSyntax extends markdown.InlineSyntax {
  RightAlignSyntax() : super(r'''<r>(.*?)</r>''');

  @override
  bool onMatch(markdown.InlineParser parser, Match match) {
    // Create an inline element with the tag 'rl'
    final element = markdown.Element.text('rl', match[1] ?? "");
    parser.addNode(element);
    return true;
  }
}


