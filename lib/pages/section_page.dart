import 'package:adapt/models/section.dart';
import 'package:adapt/services/comment_service.dart';
import 'package:adapt/services/section_service.dart';
import 'package:adapt/utils/app_colors.dart';
import 'package:adapt/widgets/image_viewer_builder.dart';
import 'package:adapt/widgets/main_title.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import '../models/comment.dart';
import '../utils/app_font_sizes.dart';
import '../utils/app_keys.dart';
import '../widgets/comment_card.dart';
import '../widgets/task_button.dart';
import '../widgets/video_viewer_builder.dart';

class SectionPage extends StatefulWidget {
  final Section section;

  const SectionPage({super.key, required this.section});

  @override
  _SectionPageState createState() => _SectionPageState();
}

class _SectionPageState extends State<SectionPage> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _commentTextController = TextEditingController();
  final SectionService _sectionService = SectionService();
  final CommentService _commentService = CommentService();

  double position = 0;

  void _scroll(double offset) {
    position = position + offset;

    if (position < 0) {
      position = 0;
    } else if (position > _scrollController.position.maxScrollExtent) {
      position = _scrollController.position.maxScrollExtent;
    }

    _scrollController.jumpTo(
      position,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: MainTitle(
            title: widget.section.sectionName,
            leadingIcon: Icons.arrow_back_ios,
            onIconPressed: () {
              moduleNavigator.currentState!.pop(); //Go Backwards
            }),
        body: FutureBuilder<String>(
          future: _sectionService.fetchSectionContent(widget.section.folderPath),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                  child: CircularProgressIndicator(color: AppColors.darkYellow));
            } else if (snapshot.hasError) {
              return const Center(child: Text("Error loading exercise"));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text("No content available"));
            }

            final markdownContent = snapshot.data!;

            return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        controller: _scrollController,
                        child: MarkdownBody(
                          data: markdownContent,
                          builders: {
                            'a': VideoViewerBuilder(),
                            'img': ImageViewerBuilder(widget.section.folderPath),
                          },
                        ),
                      ),
                    ),
                    SizedBox(
                        height: 80, // Set the desired height
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.arrow_back_ios, color: AppColors.darkYellow, size: 25),
                              // Static color
                              onPressed: () => _scroll(-250),
                            ),
                            Expanded(
                              child: TaskButton(
                                text: 'Comment',
                                onPressed: () {
                                  showModalBottomSheet(
                                    useSafeArea: true,
                                    context: context,
                                    isScrollControlled: true,
                                    shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.vertical(
                                          top: Radius.circular(12.0)), // Adjust the top corners
                                    ),
                                    builder: (BuildContext context) {
                                      return FutureBuilder<List<Comment>>(
                                        future: _commentService.fetchComments(sectionId: widget.section.sectionId),
                                        builder: (context, snapshot) {
                                          if (snapshot.connectionState == ConnectionState.waiting) {
                                            return const Center(child: CircularProgressIndicator(color: AppColors.darkYellow));
                                          } else if (snapshot.hasError) {
                                            return const Center(child: Text("Error loading comments"));
                                          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                                            return const Center(child: Text("No comments available"));
                                          }

                                          final List<Comment> comments = snapshot.data!;

                                          return Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                // Title with Close Button
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    const SizedBox(width: 24), // Placeholder to align the title center
                                                    const Text(
                                                      'Comments',
                                                      style: TextStyle(
                                                        color: AppColors.fontColor,
                                                        fontSize: AppFontSizes.small,
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    ),
                                                    IconButton(
                                                      icon: const Icon(Icons.close),
                                                      onPressed: () {
                                                        Navigator.pop(context); // Close the bottom sheet
                                                      },
                                                    ),
                                                  ],
                                                ),
                                                const Divider(
                                                  color: AppColors.lightGrey,
                                                  // Customize the color as needed
                                                  thickness: 2.5, // Customize the thickness as needed
                                                ),
                                                Flexible(
                                                  // Use Expanded to allow ListView to take remaining space
                                                  child: ListView.separated(
                                                    shrinkWrap: true,
                                                    itemCount: comments.length,
                                                    itemBuilder: (context, index) {
                                                      return CommentCard(comment: comments[index]);
                                                    },
                                                    separatorBuilder: (context, index) {
                                                      return const Divider(
                                                        color: AppColors.lightGrey,
                                                        thickness: 2.5,
                                                      );
                                                    },
                                                  ),
                                                ),
                                                Row(
                                                  children: [
                                                    Expanded(
                                                      child: TextField(
                                                        controller: _commentTextController, // Add a controller to get the text input
                                                        maxLines: null, // Makes the TextField multiline
                                                        decoration: InputDecoration(
                                                          labelText: 'Write a comment...',
                                                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(6.0)),
                                                        ),
                                                      ),
                                                    ),
                                                    IconButton(
                                                      icon: const Icon(Icons.send_rounded, color: AppColors.darkYellow, size: 25),
                                                      onPressed: () {
                                                        _commentService.addComment(_commentTextController.text.trim(), widget.section.sectionId);
                                                        _commentTextController.clear();
                                                        Navigator.pop(context); // Close the bottom sheet
                                                      },
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      );
                                    },
                                  );
                                },
                              ),
                            ),
                            IconButton(
                              icon: const Icon(
                                  Icons.arrow_forward_ios,
                                  color: AppColors.darkYellow, size: 25
                              ),
                              // Static color
                              onPressed: () => _scroll(250),
                            ),
                          ],
                        ))
                  ],
                ));
          },
        ));
  }
}
