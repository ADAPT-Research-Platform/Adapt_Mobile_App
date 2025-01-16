import 'package:adapt/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class VideoViewerBuilder extends MarkdownElementBuilder {
  bool isVideoPlaying = false; // To track if the video is playing

  @override
  Widget? visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    final url = element.attributes['href'];
    final videoId = YoutubePlayer.convertUrlToId(url ?? '');
    if (videoId != null) {
      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return GestureDetector(
            onTap: () {
              setState(() {
                isVideoPlaying = true; // Switch to video player when clicked
              });
            },
            child: isVideoPlaying ? VideoViewer(videoId: videoId) : VideoThumbnail(videoId: videoId),
          );
        },
      );
    }
    return null;
  }
}

class VideoThumbnail extends StatelessWidget {
  final String videoId;

  const VideoThumbnail({super.key, required this.videoId});

  @override
  Widget build(BuildContext context) {
    final String thumbnailUrl = 'https://img.youtube.com/vi/$videoId/0.jpg';

    return Stack(
      alignment: Alignment.center,
      children: [
         AspectRatio(
          aspectRatio: 16 / 9,
          child: Container(
            decoration: BoxDecoration(
                image: DecorationImage(
                  fit: BoxFit.fitWidth,
                  alignment: FractionalOffset.center,
                  image: NetworkImage(thumbnailUrl),
                )
            ),
          ),
        ),
        const Icon(Icons.play_circle_outline_rounded, size: 60, color: AppColors.white),
      ],
    );
  }
}

class VideoViewer extends StatelessWidget {
  final String videoId;

  const VideoViewer({super.key, required this.videoId});

  @override
  Widget build(BuildContext context) {
    return YoutubePlayer(
        controller: YoutubePlayerController(
          initialVideoId: videoId,
          flags: const YoutubePlayerFlags(
            autoPlay: true,
            mute: false,
            enableCaption: false,
            showLiveFullscreenButton: false
          ),
        ),
        showVideoProgressIndicator: true,
      );
  }
}
