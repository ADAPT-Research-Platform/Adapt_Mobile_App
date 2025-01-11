import 'package:adapt/utils/app_colors.dart';
import 'package:flutter/material.dart';

import '../models/comment.dart';
import '../utils/app_font_sizes.dart';

class CommentCard extends StatefulWidget {
  final Comment comment;

  const CommentCard({Key? key, required this.comment}) : super(key: key);

  @override
  _CommentCardState createState() => _CommentCardState();
}

class _CommentCardState extends State<CommentCard> {
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
                  widget.comment.user.userName,
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
                  _isRepliesVisible ? 'Hide Replies' : '${widget.comment.comments.length} Replies',
                  style: const TextStyle(color: AppColors.darkYellow),
                ),
              ),
            ),
          if (_isRepliesVisible)
            Padding(
              padding: const EdgeInsets.only(left: 18.0),
              child: Column(
                children: widget.comment.comments
                    .map((reply) => CommentCard(comment: reply))
                    .toList(),
              ),
            ),
        ],
      );
  }
}
