import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:logging/logging.dart';
import 'package:markdown/markdown.dart' as md;

import '../../utils/app_config.dart';

class ImageViewerBuilder extends MarkdownElementBuilder {
  static final log = Logger('ImageViewerBuilder');

  final String sectionFolderPath;

  ImageViewerBuilder(this.sectionFolderPath);

  @override
  Widget? visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    if (element.attributes['src'] != null) {
      final imageName = element.attributes['src'];
      final imageUrl = '${AppConfig.contentUrl}/$sectionFolderPath/$imageName';

      return Image.network(
        imageUrl,
        headers: {
          'Authorization': 'Bearer ${AppConfig.contentAccessToken}',
          'Accept': 'application/vnd.github.v3.raw',
        },
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          log.severe('Image loading error: $error URL: $imageUrl');
          return const Icon(Icons.broken_image_rounded);
        },
      );
    }
    return null;
  }
}
