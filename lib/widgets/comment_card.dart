import 'package:adapt/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

import '../models/comment.dart';
import '../services/comment_service.dart';
import '../utils/app_font_sizes.dart';

class CommentCard extends StatefulWidget {
  final Comment comment;

  const CommentCard({Key? key, required this.comment}) : super(key: key);

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
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const Icon(
                  Icons.circle,
                  size: 15, // Adjust size as needed
                  color: AppColors.primaryYellow, // Adjust color as needed
                ),
                SizedBox(width: 10), // Add spacing between the dot and username
                Text(
                  widget.comment.commentUserName,
                  style: const TextStyle(
                    color: AppColors.fontColor, // Static text color
                    fontSize: AppFontSizes.small,
                    fontWeight: FontWeight.bold, // Static font size
                  ),
                ),
                const Spacer(),
                Text(
                  '${widget.comment.timeStamp.day}.${widget.comment.timeStamp.month}.${widget.comment.timeStamp.year}',
                  style: const TextStyle(
                    color: AppColors.fontColor, // Static text color
                    fontSize: AppFontSizes.mini, // Static font size
                  ),
                ),
              ],
            ),
            subtitle: Text(widget.comment.text,
                style: const TextStyle(
                  color: AppColors.fontColor, // Static text color
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
                  _isRepliesVisible ? 'Hide Replies' : 'View ${widget.comment.comments.length} Replies',
                  style: const TextStyle(color: AppColors.darkYellow),
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
                      .map((reply) => CommentCard(comment: reply)),
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
                                      Text(
                                        "Reply to ${widget.comment.commentUserName}",
                                        style: const TextStyle(
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
                                  Row(
                                    children: [
                                      Expanded(
                                        child: TextField(
                                          controller: _commentTextController, // Add a controller to get the text input
                                          maxLines: null, // Makes the TextField multiline
                                          decoration: InputDecoration(
                                            labelText: 'Write a reply...',
                                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(6.0)),
                                          ),
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.send_rounded, color: AppColors.darkYellow, size: 25),
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
                      child: const Text(
                        'Reply',
                        style: TextStyle(
                            color: AppColors.darkYellow,
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
