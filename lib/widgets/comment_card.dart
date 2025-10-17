import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

import '../models/comment.dart';
import '../services/comment_service.dart';
import '../services/localization_service.dart';
import '../utils/app_font_sizes.dart';
import '../utils/time_formatter.dart';

class CommentCard extends StatefulWidget {
  final Comment comment;
  final bool isChapterShowing;
  final bool isEnableReply;

  const CommentCard({super.key, required this.comment, required this.isChapterShowing, required this.isEnableReply});

  @override
  _CommentCardState createState() => _CommentCardState();
}

class _CommentCardState extends State<CommentCard> {
  final log = Logger('CommentCard');

  final TextEditingController _commentTextController = TextEditingController();
  final CommentService _commentService = CommentService();

  bool _isRepliesVisible = false;

  @override
  Widget build(BuildContext context) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if(widget.isChapterShowing)
            Text(
              'Module ${widget.comment.moduleId}: Chapter ${widget.comment.chapterIndex}',
              style: const TextStyle(
                fontSize: AppFontSizes.small,
                fontWeight: FontWeight.bold, // Static font size
              ),
            ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Icon(
                  Icons.circle,
                  size: 15, // Adjust size as needed
                  color: Theme.of(context).primaryColorLight, // Adjust color as needed
                ),
                const SizedBox(width: 10), // Add spacing between the dot and username
                Text(
                  widget.comment.commentUserName,
                  style: const TextStyle(
                    fontSize: AppFontSizes.small,
                    fontWeight: FontWeight.bold, // Static font size
                  ),
                ),
                const Spacer(),
                Text(
                  formatTimeAgoShort(widget.comment.timeStamp),
                  style: const TextStyle(
                    fontSize: AppFontSizes.mini, // Static font size
                  ),
                ),
              ],
            ),
            subtitle: Text(widget.comment.text,
                style: const TextStyle(
                  fontSize: AppFontSizes.mini, // Static font size
                )),
          ),
          if (widget.comment.comments.isNotEmpty)
            GestureDetector(
              onTap: () {
                setState(() {
                  _isRepliesVisible = !_isRepliesVisible;
                });
              },
              child: Padding(
                padding: const EdgeInsets.only(left: 18.0),
                child: Text(
                  _isRepliesVisible ? LocalizationService().get('hide_replies') : '${LocalizationService().get('View')} ${widget.comment.comments.length} ${LocalizationService().get('Replies')}',
                  style: TextStyle(color: Theme.of(context).primaryColorDark),
                ),
              ),
            ),
          if (_isRepliesVisible)
            Padding(
              padding: const EdgeInsets.only(left: 18.0),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    ...widget.comment.comments
                      .map((reply) => CommentCard(comment: reply,isChapterShowing: false, isEnableReply: false)),
                    if(widget.isEnableReply)
                      GestureDetector(
                        onTap: () {
                          log.info("Replied to ${widget.comment.commentId}..");
                          showModalBottomSheet(
                            useSafeArea: true,
                            context: context,
                            isScrollControlled: true,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(12.0)), // Adjust the top corners
                            ),
                            builder: (BuildContext context) {
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
                                        Expanded(
                                          child: Text(
                                            "${LocalizationService().get('reply_to')} ${widget.comment.commentUserName}",
                                            style: const TextStyle(
                                              fontSize: AppFontSizes.small,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          )
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
                                    Row(
                                      children: [
                                        Expanded(
                                          child: TextField(
                                            controller: _commentTextController, // Add a controller to get the text input
                                            maxLines: null, // Makes the TextField multiline
                                            decoration: InputDecoration(
                                              labelText: LocalizationService().get('write_a_reply'),
                                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(6.0)),
                                            ),
                                          ),
                                        ),
                                        IconButton(
                                          icon: Icon(Icons.send_rounded, color: Theme.of(context).primaryColorDark, size: 25),
                                          onPressed: () {
                                            _commentService.addReply(_commentTextController.text.trim(), widget.comment.commentId);
                                            _commentTextController.clear();
                                            Navigator.pop(context); // Close the bottom sheet
                                            Navigator.pop(context);
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
                        child: Text(
                          LocalizationService().get('Reply'),
                          style: TextStyle(
                              color: Theme.of(context).primaryColorDark,
                              fontWeight: FontWeight.bold
                          ),
                        ),
                      ),
                  ]
              ),
            ),
        ],
      );
  }
}
