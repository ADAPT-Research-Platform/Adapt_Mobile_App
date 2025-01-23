import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:markdown/markdown.dart' as markdown;

class UnderlineBuilder extends MarkdownElementBuilder {
  
  @override
  Widget visitText(text, preferredStyle) {
    return SizedBox(
        width: double.infinity,
        child: SelectableText.rich(
          TextSpan(
              text: text.textContent,
              style: const TextStyle(
                color: Colors.black87,
                decoration: TextDecoration.underline,
              )),
        ));
  }
}

class UnderlineSyntax extends markdown.InlineSyntax {
  UnderlineSyntax() : super(r'''<u>(.*?)</u>''');

  @override
  bool onMatch(markdown.InlineParser parser, Match match) {
    markdown.Element ulTag = markdown.Element.text('ul', match[1] ?? "");
    parser.addNode(ulTag);
    return true;
  }
}