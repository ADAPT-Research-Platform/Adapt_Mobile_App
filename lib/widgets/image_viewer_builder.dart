import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:markdown/markdown.dart' as md;

class ImageViewerBuilder extends MarkdownElementBuilder {
  final String baseUrl;

  ImageViewerBuilder(this.baseUrl);

  @override
  Widget? visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    // Check if the element is an image
    if (element.attributes['src'] != null) {
      final imageUrl = element.attributes['src'];
      final updatedUrl = '$baseUrl/$imageUrl';

      // Return an image widget with the updated URL
      return Image.network(
        updatedUrl,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return const Icon(Icons.broken_image);
        },
      );
    }
    return null;
  }
}
