import 'dart:convert';
import 'dart:math';

import 'package:adapt/enums/language.dart';
import 'package:adapt/models/answer.dart';
import 'package:adapt/models/chapter.dart';
import 'package:adapt/models/module.dart';
import 'package:adapt/services/chapter_service.dart';
import 'package:adapt/services/comment_service.dart';
import 'package:adapt/services/module_service.dart';
import 'package:adapt/utils/app_routes.dart';
import 'package:adapt/widgets/main_title.dart';
import 'package:adapt/widgets/markdown_builders/right_align_text_builder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:logging/logging.dart';

import '../models/checkbox_answer.dart';
import '../models/checkbox_question.dart';
import '../models/comment.dart';
import '../services/localization_service.dart';
import '../utils/app_font_sizes.dart';
import '../utils/app_keys.dart';
import '../utils/score_store.dart';
import '../widgets/comment_card.dart';
import '../widgets/markdown_builders/checkbox_question_builder.dart';
import '../widgets/markdown_builders/conditional_text_builder.dart';
import '../widgets/markdown_builders/header_builder.dart';
import '../widgets/markdown_builders/image_viewer_builder.dart';
import '../widgets/markdown_builders/markdown_styles.dart';
import '../widgets/markdown_builders/question_viewer_builder.dart';
import '../widgets/markdown_builders/underline_text_builder.dart';
import '../widgets/markdown_builders/video_viewer_builder.dart';
import '../widgets/task_button.dart';

class ChapterPage extends StatefulWidget {
  final Chapter section;
  final String moduleId;

  const ChapterPage({super.key, required this.section, required this.moduleId});

  @override
  _ChapterPageState createState() => _ChapterPageState();
}

class _ChapterPageState extends State<ChapterPage> {
  final log = Logger('SectionPage');

  final ScrollController _scrollController = ScrollController();
  final TextEditingController _commentTextController = TextEditingController();
  final ChapterService _chapterService = ChapterService();
  final CommentService _commentService = CommentService();
  final ModuleService _moduleService = ModuleService();
  Chapter? _nextChapter;

  final Map<String, TextEditingController> _controllers = {};
  final Map<String, String> _questions = {};
  final Map<String, String> _answers = {};

  final ValueNotifier<Map<String, CheckboxQuestion>> _userSelectionsNotifier = ValueNotifier({});

  // Make _checkboxBuilder nullable and initialize it in initState
  late final ScoreStore _scoreStore;
  late final String chapterKey = "M${widget.moduleId}C${widget.section.chapterIndex}";

  double maxScrollPixels = 0.0;

  void _submitAnswers() {
    for (var key in _questions.keys) {
      _answers[key] = _controllers[key]?.text ?? "";
    }

    _chapterService.addAnswer(widget.section.chapterId, _answers);
    log.info("Submitted Answers: ${jsonEncode(_answers)}");
  }

  void _updateMaxScrollPixels() {
    //Memorize how much max he scrolled
    double currentScroll = _scrollController.position.pixels;
    maxScrollPixels = max(maxScrollPixels, currentScroll);
  }

  void _updateSectionProgress() {
    // For exercises use different strategy. Percentage means how many questions have answered
    if (widget.section.isExercise) {
      // Count total number of questions
      int totalQuestions = _questions.length;

      // Count the number of valid answers (non-null and non-empty)
      int validAnswers = _answers.values.where((answer) => answer.isNotEmpty).length;

      double exerciseProgress = (validAnswers / totalQuestions) * 100;
      _chapterService.updateProgress(widget.section.chapterId, exerciseProgress);
      return;
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
    if (readingProgress > widget.section.progress) {
      _chapterService.updateProgress(widget.section.chapterId, readingProgress);
    }
    return;
  }

  void _onCheckboxChanged(String questionId, int index, bool isChecked) {
    final newSelections = Map<String, CheckboxQuestion>.from(_userSelectionsNotifier.value);
    final CheckboxQuestion? questionData = _userSelectionsNotifier.value[questionId];

    if(questionData != null){
      if(questionData.multiple){
        if (isChecked) {
          questionData.selectedAnswers.add(index);
        } else {
          questionData.selectedAnswers.remove(index);
        }
      }else{
        questionData.selectedAnswers.clear();
        questionData.selectedAnswers.add(index);
      }

      log.info("$chapterKey = ${questionData.selectedAnswers}");
      _userSelectionsNotifier.value = newSelections;
    }
  }

  void _saveCurrentAnswersAndScore() {
    final newSelections = _userSelectionsNotifier.value;

    if(newSelections.isEmpty){
      return;
    }

    final Map<String, Set<int>> currentAnswers = newSelections.map((questionId, questionData) {
      return MapEntry(questionId, questionData.selectedAnswers);
    });

    // Calculate the total score from all selected answers
    int totalScore = 0;
    newSelections.forEach((questionId, questionData) {
      totalScore += questionData.score;
    });

    log.info("totalScore: $totalScore");

    _scoreStore.setChapterAnswers(chapterKey, currentAnswers);
    _scoreStore.setChapterScore('${chapterKey}S', totalScore);
  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_updateMaxScrollPixels);
    _loadNextChapter();
    _scoreStore = ScoreStore(); // shared instance
  }

  Future<void> _loadNextChapter() async {
    try {
      Module module = await _moduleService.fetchModuleById(widget.moduleId);
      int currentIndex = module.chapters.indexWhere((c) => c.chapterId == widget.section.chapterId);
      if (currentIndex != -1 && currentIndex < module.chapters.length - 1) {
        setState(() {
          _nextChapter = module.chapters[currentIndex + 1];
        });
      }
    } catch (e) {
      log.severe('Error loading next chapter: $e');
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    _scrollController.dispose();
    _commentTextController.dispose();
    _userSelectionsNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: MainTitle(
            title: widget.section.isExercise
                ? '${LocalizationService().get('Chapter')} ${widget.section.chapterIndex}: ${LocalizationService().get('Exercise')}'
                : '${LocalizationService().get('Chapter')} ${widget.section.chapterIndex}',
            leadingIcon: Icons.arrow_back_ios_rounded,
            actions: [
              if (_nextChapter != null)
                TextButton(
                  onPressed: () {
                    moduleNavigator.currentState!.pushReplacementNamed(
                      Routes.routeSections,
                      arguments: {'section': _nextChapter, 'moduleId': widget.moduleId},
                    );
                  },
                  child: Text(LocalizationService().get('next'), style: TextStyle(color: Theme.of(context).primaryColorDark, fontSize: AppFontSizes.small),),
                ),
            ],
            onIconPressed: () {
              _saveCurrentAnswersAndScore();
              _updateSectionProgress();
              moduleNavigator.currentState!.pop(); //Go Backwards
            }),
        body: FutureBuilder<List<dynamic>>(
          future: Future.wait([
            _chapterService.fetchChapterContent('${widget.section.folderPath}/content_${LocalizationService().getSelectedLanguage().code}.md'),
            _scoreStore.getChapterAnswers(chapterKey),
            if (widget.section.isExercise) _chapterService.fetchAnswerByChapterId(widget.section.chapterId),
          ]),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator(color: Theme.of(context).primaryColorDark));
            } else if (snapshot.hasError) {
              return Center(child: Text(LocalizationService().get("error_loading_chapter_content")));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(child: Text(LocalizationService().get("no_chapter_content")));
            }

            // Extract data
            final String markdownContent = snapshot.data![0];

            final Map<String, Set<int>> previousAnswers = snapshot.data![1];

            if (widget.section.isExercise && snapshot.data![2] != null) {
              Answer answer = snapshot.data![2];
              _answers.addAll(answer.text);
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
                        child: SingleChildScrollView(
                          controller: _scrollController,
                          child: MarkdownBody(
                            data: markdownContent,
                            styleSheet: MarkdownStyles.getMarkdownStyleSheet(context),
                            blockSyntaxes: [CheckboxQuestionSyntax(), QuestionSyntax(), ConditionalTextSyntax()],
                            inlineSyntaxes: [UnderlineSyntax(), RightAlignSyntax()],
                            selectable: false,
                            builders: <String, MarkdownElementBuilder>{
                              'a': VideoViewerBuilder(),
                              'img': ImageViewerBuilder(widget.section.folderPath),
                              'h3': CenteredHeaderBuilder(),
                              'question': QuestionViewerBuilder(
                                  _questions,
                                  _answers,
                                  _controllers
                              ),
                              'checkbox': CheckboxQuestionViewerBuilder(
                                  _userSelectionsNotifier,
                                  previousAnswers,
                                  _onCheckboxChanged,
                                  Theme.of(context).cardColor,
                                  Theme.of(context).primaryColorLight
                              ),
                              'ul': UnderlineBuilder(),
                              'rl': RightAlignBuilder(),
                              'if': ConditionalTextBuilder(_scoreStore),
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
                                text: LocalizationService().get('Comment'),
                                icon: Icons.comment_rounded,
                                onPressed: _showModalBottomSheet
                              ),
                            ),
                            if (widget.section.isExercise) ...[
                              const SizedBox(width: 10),
                              Expanded(
                                  child: TaskButton(
                                    text: LocalizationService().get('Submit'),
                                    icon: Icons.question_answer_rounded,
                                    onPressed: _submitAnswers,
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

  void _showModalBottomSheet(){
    showModalBottomSheet(
      useSafeArea: true,
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12.0)), // Adjust the top corners
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
                  Text(
                    LocalizationService().get('Comments'),
                    style: const TextStyle(
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
              Divider(
                color: Theme.of(context).dividerColor,
                // Customize the color as needed
                thickness: 2.5, // Customize the thickness as needed
              ),
              Expanded( // Use Expanded here
                child: FutureBuilder<List<Comment>>(
                  future: _commentService.fetchCommentsByChapterId(widget.section.chapterId),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator(color: Theme.of(context).primaryColorDark));
                    } else if (snapshot.hasError) {
                      return Center(child: Text(LocalizationService().get("error_loading_comments")));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Center(child: Text(LocalizationService().get("no_comments")));
                    }

                    final List<Comment> comments = snapshot.data!;

                    return ListView.separated(
                      shrinkWrap: true,
                      itemCount: comments.length,
                      itemBuilder: (context, index) {
                        return CommentCard(comment: comments[index], isChapterShowing: false, isEnableReply: true);
                      },
                      separatorBuilder: (context, index) {
                        return Divider(
                          color: Theme.of(context).dividerColor,
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
                        labelText: LocalizationService().get('write_a_comment'),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(6.0)),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.send_rounded, color: Theme.of(context).primaryColorDark, size: 25),
                    onPressed: () {
                      _commentService.addComment(_commentTextController.text.trim(), widget.section.chapterId);
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
  }
}
