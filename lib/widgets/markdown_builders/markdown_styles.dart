import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class MarkdownStyles {

  static MarkdownStyleSheet getMarkdownStyleSheet(BuildContext context) {
    return MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
      blockquoteDecoration: BoxDecoration(
        color: Theme.of(context).cardColor, // Darker background for the quote block
        border: Border(
          left: BorderSide(
            color: Theme.of(context).primaryColorLight, // Use accent color for the left bar
            width: 4.0,
          ),
        ),
      ),
    );
  }
}
