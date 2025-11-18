import 'package:adapt/utils/app_font_sizes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class MarkdownStyles {

  static MarkdownStyleSheet getMarkdownStyleSheet(BuildContext context) {
    return MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
      // Slightly larger font size for the paragraph text
      p: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 18),
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
