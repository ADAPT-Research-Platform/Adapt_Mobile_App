import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:markdown/markdown.dart' as md;

import '../sub_title.dart';

class CenteredHeaderBuilder extends MarkdownElementBuilder {

  @override
  Widget visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    return SubTitle(text: element.textContent);
  }
}