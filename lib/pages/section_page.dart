import 'dart:convert';
import 'dart:math';

import 'package:adapt/models/section.dart';
import 'package:adapt/services/comment_service.dart';
import 'package:adapt/services/section_service.dart';
import 'package:adapt/utils/app_colors.dart';
import 'package:adapt/widgets/image_viewer_builder.dart';
import 'package:adapt/widgets/main_title.dart';
import 'package:adapt/widgets/question_viewer_builder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:logging/logging.dart';

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
  final log = Logger('SectionPage');

  final ScrollController _scrollController = ScrollController();
  final TextEditingController _commentTextController = TextEditingController();
  final SectionService _sectionService = SectionService();
  final CommentService _commentService = CommentService();

  final Map<String, TextEditingController> _controllers = {};
  final Map<String, String> _questions = {};
  final Map<String, String> _answers = {};

  double maxScrollPixels = 0.0;

  void _submitAnswers() {
    for (var key in _questions.keys) {
      _answers[key] = _controllers[key]?.text ?? "";
    }

    _sectionService.addAnswer(widget.section.sectionId, _answers);
    log.info("Submitted Answers: ${jsonEncode(_answers)}");
  }

  void _updateMaxScrollPixels() {
    //Memorize how much max he scrolled
    double currentScroll = _scrollController.position.pixels;
    maxScrollPixels = max(maxScrollPixels, currentScroll);
  }

  void _updateSectionProgress() {
    // For exercises use different strategy. Percentage means how many questions have answered
    if(widget.section.isExercise){
      // Count total number of questions
      int totalQuestions = _questions.length;

      // Count the number of valid answers (non-null and non-empty)
      int validAnswers = _answers.values.where((answer) => answer.isNotEmpty).length;

      double exerciseProgress = (validAnswers / totalQuestions) * 100;
      _sectionService.updateProgress(widget.section.sectionId, exerciseProgress);
      return ;
    }

    // For reading section use different strategy. How much the user maximum scrolled so far
    if (!_scrollController.hasClients) {
      return;
    }

    final double maxScrollExtent = _scrollController.position.maxScrollExtent;
    final double viewportHeight = _scrollController.position.viewportDimension;

    // Total scrollable height includes the visible portion (viewportHeight)
    final double totalContentHeight = maxScrollExtent + viewportHeight;

    // Calculate percentage based on visible + scrolled content
    final double visibleScrolledContent = maxScrollPixels + viewportHeight;
    final double percentage = (visibleScrolledContent / totalContentHeight) * 100;

    // Clamp percentage between 0 and 100
    double readingProgress = percentage.clamp(0, 100);
    if(readingProgress > widget.section.progress){
      _sectionService.updateProgress(widget.section.sectionId, readingProgress);
    }
    return ;
  }


  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_updateMaxScrollPixels);
  }

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    _scrollController.dispose();
    _commentTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: MainTitle(
            title: widget.section.sectionName,
            leadingIcon: Icons.arrow_back_ios_rounded,
            onIconPressed: () {
              _updateSectionProgress();
              moduleNavigator.currentState!.pop(); //Go Backwards
            }),
        body: FutureBuilder<List<dynamic>>(
          future: Future.wait([
            _sectionService.fetchSectionContent(widget.section.folderPath),
            if (widget.section.isExercise)
              _sectionService.fetchAnswer(widget.section.sectionId),
          ]),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: AppColors.darkYellow));
            } else if (snapshot.hasError) {
              return const Center(child: Text("Error loading content!"));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text("No content available!"));
            }

            // Extract data
            final String markdownContent = snapshot.data![0];

            if (widget.section.isExercise) {
              _answers.addAll(snapshot.data![1]);
            }

            return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Column(
                  children: [
                    Expanded(
                      child: Scrollbar(
                        controller: _scrollController,
                        radius: const Radius.circular(10.0),
                        thickness: 5,
                        thumbVisibility: true,
                        //trackVisibility: true,
                        child: SingleChildScrollView(
                          controller: _scrollController,
                          child: MarkdownBody(
                            data: markdownContent,
                            blockSyntaxes: [QuestionSyntax()],
                            selectable: false,
                            builders: <String, MarkdownElementBuilder>{
                              'a': VideoViewerBuilder(),
                              'img': ImageViewerBuilder(widget.section.folderPath),
                              'question': QuestionViewerBuilder(_questions, _answers, _controllers),
                            },
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                        height: 80, // Set the desired height
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Expanded(
                              child: TaskButton(
                                text: 'Comment',
                                icon: Icons.comment_rounded,
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
                                      final maxHeight = 2 * MediaQuery.of(context).size.height / 3;

                                      return Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                                        constraints: BoxConstraints(maxHeight: maxHeight), // Set minimum height
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
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
                                                  icon: const Icon(Icons.close_rounded),
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
                                            Expanded( // Use Expanded here
                                              child: FutureBuilder<List<Comment>>(
                                                  future: _commentService.fetchComments(sectionId: widget.section.sectionId),
                                                  builder: (context, snapshot) {
                                                    if (snapshot.connectionState == ConnectionState.waiting) {
                                                      return const Center(child: CircularProgressIndicator(color: AppColors.darkYellow));
                                                    } else if (snapshot.hasError) {
                                                      return const Center(child: Text("Error loading comments!"));
                                                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                                                      return const Center(child: Text("No comments available!"));
                                                    }

                                                    final List<Comment> comments = snapshot.data!;

                                                    return ListView.separated(
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
                              ),
                            ),
                            if (widget.section.isExercise) ...[
                              const SizedBox(width: 10,),
                              Expanded(
                                  child: TaskButton(
                                    text: 'Submit',
                                    onPressed: _submitAnswers,
                                    backgroundColor: AppColors.darkYellow,
                                    icon: Icons.question_answer_rounded,
                                  )
                              )
                            ]
                          ],
                        ))
                  ],
                ));
          },
        ));
  }
}
