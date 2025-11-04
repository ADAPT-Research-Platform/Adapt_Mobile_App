import 'package:easy_image_viewer/easy_image_viewer.dart';
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

      return ImageViewer(
        imageUrl: imageUrl,
        headers: {
          'Authorization': 'Bearer ${AppConfig.contentAccessToken}',
          'Accept': 'application/vnd.github.v3.raw',
        },
      );
    }
    return null;
  }
}

class ImageViewer extends StatelessWidget {
  final String imageUrl;
  final Map<String, String> headers;

  const ImageViewer({super.key, required this.imageUrl, required this.headers});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showImageViewer(
          context,
          NetworkImage(
            imageUrl,
            headers: headers,
          ),
          doubleTapZoomable: true,
        );
      },
      child: Image.network(
        imageUrl,
        headers: headers,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          ImageViewerBuilder.log.severe('Image loading error: $error URL: $imageUrl');
          return const Icon(Icons.broken_image_rounded);
        },
      ),
    );
  }
}