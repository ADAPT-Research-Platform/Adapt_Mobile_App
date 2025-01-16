import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:markdown/markdown.dart' as md;

import '../utils/app_config.dart';

class ImageViewerBuilder extends MarkdownElementBuilder {
  final String sectionFolderPath;

  ImageViewerBuilder(this.sectionFolderPath);

  @override
  Widget? visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    // Check if the element is an image
    if (element.attributes['src'] != null) {
      final imageName = element.attributes['src'];
      final imageUrl = 'http://${AppConfig.serverIp}:${AppConfig.port}/app/uploads/$sectionFolderPath/$imageName';

      // Return an image widget with the updated URL
      return Image.network(
        imageUrl,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return const Icon(Icons.broken_image_rounded);
        },
      );
    }
    return null;
  }
}
