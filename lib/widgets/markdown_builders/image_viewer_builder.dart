import 'dart:math';

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
        showDialog(
          context: context,
          builder: (context) => _CustomImageViewer(
            imageUrl: imageUrl,
            headers: headers,
          ),
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

class _CustomImageViewer extends StatefulWidget {
  final String imageUrl;
  final Map<String, String> headers;

  const _CustomImageViewer({required this.imageUrl, required this.headers});

  @override
  State<_CustomImageViewer> createState() => _CustomImageViewerState();
}

class _CustomImageViewerState extends State<_CustomImageViewer> {
  int _quarterTurns = 0;
  late final TransformationController _transformationController;

  @override
  void initState() {
    super.initState();
    _transformationController = TransformationController();
  }

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: InteractiveViewer(
              key: ValueKey<int>(_quarterTurns),
              transformationController: _transformationController,
              constrained: (_quarterTurns % 2 == 0), // Constrained in portrait, not in landscape
              minScale: 0.1,
              maxScale: 4.0,
              child: RotatedBox(
                quarterTurns: _quarterTurns,
                child: Image.network(
                  widget.imageUrl,
                  headers: widget.headers,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(Icons.broken_image_rounded, color: Colors.white);
                  },
                ),
              ),
            ),
          ),
          Positioned(
            top: 20,
            right: 20,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 30),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          Positioned(
            bottom: 20,
            left: 20,
            child: IconButton(
              icon: const Icon(Icons.center_focus_strong, color: Colors.white, size: 30),
              onPressed: () {
                _transformationController.value = Matrix4.identity();
              },
            ),
          ),
          Positioned(
            bottom: 20,
            right: 20,
            child: IconButton(
              icon: const Icon(Icons.rotate_90_degrees_cw, color: Colors.white, size: 30),
              onPressed: () {
                setState(() {
                  _quarterTurns++;
                  // Reset zoom/pan on rotation to avoid confusion
                  _transformationController.value = Matrix4.identity();
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}