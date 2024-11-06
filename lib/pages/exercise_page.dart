import 'package:adapt/models/exercise.dart';
import 'package:adapt/services/firebase_exercise_service.dart';
import 'package:adapt/utils/app_colors.dart';
import 'package:adapt/widgets/app_title_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import '../models/comment.dart';
import '../models/user.dart';
import '../utils/navigator_keys.dart';
import '../utils/string_formatter.dart';
import '../widgets/app_comment_card.dart';
import '../widgets/youtube_player_builder.dart';

class ExercisePage extends StatefulWidget {
  final Exercise exercise;

  const ExercisePage({super.key, required this.exercise});

  @override
  _ExercisePageState createState() => _ExercisePageState();
}

class _ExercisePageState extends State<ExercisePage> {
  final ScrollController _scrollController = ScrollController();
  final FirebaseExerciseService _firebaseExerciseService = FirebaseExerciseService();

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

  //Fake Data
  List<Comment> comments = [
    Comment(
      commentId: '6',
      user: User(
          userId: 'AJc7VO6q5McHHFlFfZVjdlmNE1K3',
          displayName: 'Leonie Krol',
          email: 'risithgmtech@gmail.com',
          createdDate: DateTime(2024, 5, 14)),
      timeStamp: DateTime(2024, 11, 1),
      text: 'How about you today?',
      replies: [
        Comment(
            commentId: '7',
            user: User(
                userId: 'xZOnZ2mQvTWTObfryho7tbetU1V2',
                displayName: 'Risith Perera',
                email: 'risithpremier@gmail.com',
                createdDate: DateTime(2024, 5, 5)),
            timeStamp: DateTime(2024, 11, 3),
            text: 'I\'m feeling great!')
      ],
    ),
    Comment(
      commentId: '1',
      user: User(
          userId: 'xZOnZ2mQvTWTObfryho7tbetU1V2',
          displayName: 'Risith Perera',
          email: 'risithpremier@gmail.com',
          createdDate: DateTime(2024, 5, 5)),
      timeStamp: DateTime(2024, 10, 19),
      text:
          'Today I did 3 times breathing exercise. Now I feel less fear. Thank you so much.',
      replies: [
        Comment(
            commentId: '2',
            user: User(
                userId: 'AJc7VO6q5McHHFlFfZVjdlmNE1K3',
                displayName: 'Leonie Krol',
                email: 'risithgmtech@gmail.com',
                createdDate: DateTime(2024, 5, 14)),
            timeStamp: DateTime(2024, 10, 21),
            text: 'Okay. That\'s Sound Fantastic...!'),
        Comment(
            commentId: '3',
            user: User(
                userId: 'xxxxxxx',
                displayName: 'Anna Zarski',
                email: 'anna@gmail.com',
                createdDate: DateTime(2024, 5, 20)),
            timeStamp: DateTime(2024, 10, 29),
            text: 'Okay. Glad to hear...!')
      ],
    ),
    Comment(
      commentId: '4',
      user: User(
          userId: 'xZOnZ2mQvTWTObfryho7tbetU1V2',
          displayName: 'Risith Perera',
          email: 'risithpremier@gmail.com',
          createdDate: DateTime(2024, 5, 5)),
      timeStamp: DateTime(2024, 10, 1),
      text: 'It is very hard to concentrate breathing. What should I do?',
      replies: [
        Comment(
            commentId: '5',
            user: User(
                userId: 'AJc7VO6q5McHHFlFfZVjdlmNE1K3',
                displayName: 'Leonie Krol',
                email: 'risithgmtech@gmail.com',
                createdDate: DateTime(2024, 5, 14)),
            timeStamp: DateTime(2024, 10, 5),
            text: 'You have to jump twice daily.')
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppTitleBar(
            title: convertIdToName(widget.exercise.exerciseId),
            leadingIcon: Icons.arrow_back_ios,
            onIconPressed: () {
              moduleNavigator.currentState!.pop(); //Go Backwards
            }),
        body: FutureBuilder<String>(
          future: _firebaseExerciseService.fetchExerciseFile(widget.exercise.url),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: AppColors.darkYellow));
            } else if (snapshot.hasError) {
              return const Center(child: Text("Error loading exercise"));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text("No exercise available"));
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
                            'a': YouTubePlayerBuilder(),
                          },
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: Icon(Icons.arrow_back_ios,
                              color: AppColors.darkYellow, size: 25),
                          // Static color
                          onPressed: () => _scroll(-250),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            foregroundColor: AppColors.white,
                            backgroundColor: AppColors.primaryYellow,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6.0),
                            ),
                          ),
                          onPressed: () {
                            showModalBottomSheet<void>(
                              useSafeArea: true,
                              context: context,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.vertical(top: Radius.circular(12.0)), // Adjust the top corners
                              ),
                              builder: (BuildContext context) {
                                return Container(
                                  // Set a fixed height for the bottom sheet
                                  height: 600, //TODO: Need adjust based on the screen size
                                  padding: EdgeInsets.all(16.0),
                                  child: Column(
                                    children: [
                                      TextField(
                                        decoration: InputDecoration(
                                          labelText: 'Write your answer here...',
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(6.0),
                                          ),
                                        ),
                                      ),
                                      //SizedBox(height: 10), // Add some space between TextField and ListView
                                      Expanded( // Use Expanded to allow ListView to take remaining space
                                        child: ListView.separated(
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
                                    ],
                                  ),
                                );
                              },
                            );
                          },
                          child: const Text('Answer'),
                        ),
                        IconButton(
                          icon: Icon(Icons.arrow_forward_ios,
                              color: AppColors.darkYellow, size: 25),
                          // Static color
                          onPressed: () => _scroll(250),
                        ),
                      ],
                    )
                  ],
                ));
          },
        ));
  }
}
