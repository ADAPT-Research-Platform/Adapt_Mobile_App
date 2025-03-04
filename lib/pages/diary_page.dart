import 'package:adapt/services/chapter_service.dart';
import 'package:adapt/services/comment_service.dart';
import 'package:adapt/services/module_service.dart';
import 'package:adapt/utils/app_colors.dart';
import 'package:adapt/widgets/answer_card.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:table_calendar/table_calendar.dart';

import '../models/answer.dart';
import '../models/comment.dart';
import '../services/localization_service.dart';
import '../utils/app_font_sizes.dart';
import '../widgets/comment_card.dart';
import '../widgets/main_title.dart';
import '../widgets/sub_title.dart';

class DiaryPage extends StatefulWidget {
  const DiaryPage({super.key});

  @override
  _DiaryPage createState() => _DiaryPage();
}

class _DiaryPage extends State<DiaryPage> {
  final log = Logger('DiaryPage');

  late DateTime _selectedDay;
  late DateTime _focusedDay;
  final ModuleService _moduleService = ModuleService();
  final CommentService _commentService = CommentService();
  final ChapterService _chapterService = ChapterService();

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
    _focusedDay = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MainTitle(title: LocalizationService().get('diary')),
      body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: FutureBuilder<List<String>>(
            future: _moduleService.fetchDiaryDateList(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: AppColors.darkYellow));
              } else if (snapshot.hasError) {
                return const Center(child: Text("Error loading diary data!"));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text("No diary data available!"));
              }

              final List<String> diaryDates = snapshot.data!;

              // Convert them to a set of DateTime objects (normalized to year, month, day)
              late final Set<DateTime> highlightedDates = diaryDates.map((dateStr) {
                final dt = DateTime.parse(dateStr);
                return DateTime(dt.year, dt.month, dt.day);
              }).toSet();

              return Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.darkWhite,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppColors.darkYellow, // Border color
                        width: 2.2, // Border width
                      ),
                    ),
                    child: TableCalendar(
                      focusedDay: _focusedDay,
                      firstDay: DateTime.utc(2020, 1, 1),
                      lastDay: DateTime.now(),
                      rowHeight: 38,
                      selectedDayPredicate: (day) => isSameDay(day, _selectedDay),
                      onDaySelected: (selectedDay, focusedDay) {
                        setState(() {
                          _selectedDay = selectedDay;
                          _focusedDay = focusedDay;
                          log.info("Selected date: $selectedDay");
                        });
                      },
                      calendarBuilders: CalendarBuilders(
                        defaultBuilder: (context, day, focusedDay) {
                          // Normalize day for comparison (ignore time part)
                          final normalizedDay = DateTime(day.year, day.month, day.day);
                          if (highlightedDates.contains(normalizedDay)) {
                            return Container(
                              margin: const EdgeInsets.all(4.0),
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.primaryYellow,
                              ),
                              child: Center(
                                child: Text(
                                  '${day.day}',
                                  style: const TextStyle(color: Colors.black),
                                ),
                              ),
                            );
                          }
                          return null; // fall back to default builder
                        },
                      ),
                      headerStyle: const HeaderStyle(
                        formatButtonVisible: false, // Hide the "2 weeks" button
                        titleCentered: true, // Center the header text
                        headerPadding: EdgeInsets.symmetric(vertical: 0.0),
                        leftChevronIcon: Icon(Icons.arrow_back_ios_rounded, color: AppColors.darkYellow, size: 32),
                        rightChevronIcon: Icon(Icons.arrow_forward_ios_rounded, color: AppColors.darkYellow, size: 32),
                        titleTextStyle: TextStyle(
                          color: AppColors.darkYellow, // Static text color
                          fontSize: AppFontSizes.medium, // Static font size
                          fontWeight: FontWeight.bold, // Static font weight
                        ),
                      ),
                      calendarStyle: const CalendarStyle(
                        //tablePadding: EdgeInsets.fromLTRB(0, 0, 0, 15),
                        cellMargin: EdgeInsets.all(4.0),
                        todayDecoration: BoxDecoration(
                          color: AppColors.darkYellow,
                          shape: BoxShape.circle,
                        ),
                        selectedDecoration: BoxDecoration(
                          color: Colors.black38,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  FutureBuilder<List<dynamic>>(
                    future: Future.wait([
                      _commentService.fetchCommentsByDate(_selectedDay),
                      _chapterService.fetchAnswerByDate(_selectedDay),
                    ]),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator(color: AppColors.darkYellow));
                      } else if (snapshot.hasError) {
                        return const Center(child: Text("Error loading diary data!"));
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Center(child: Text("No diary data available!"));
                      }

                      final List<Comment> comments = snapshot.data![0];
                      final List<Answer> answers = snapshot.data![1];

                      return Expanded(
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                if (comments.isNotEmpty)
                                  ExpansionTile(
                                    title: SubTitle(text: LocalizationService().get('comments')),
                                    iconColor: AppColors.darkYellow,
                                    collapsedIconColor: AppColors.darkYellow,
                                    children: [
                                      ...List.generate(comments.length * 2 - 1, (index) {
                                        if (index.isEven) {
                                          return CommentCard(comment: comments[index ~/ 2], isChapterShowing: true);
                                        } else {
                                          return const Divider(
                                            color: AppColors.lightGrey,
                                            thickness: 2.5,
                                          );
                                        }
                                      }),
                                    ],
                                  ),
                                if (answers.isNotEmpty)
                                  ExpansionTile(
                                    title: SubTitle(text: LocalizationService().get('answers')),
                                    iconColor: AppColors.darkYellow,
                                    collapsedIconColor: AppColors.darkYellow,
                                    children: [
                                      ...List.generate(answers.length * 2 - 1, (index) {
                                        if (index.isEven) {
                                          return AnswerCard(answer: answers[index ~/ 2]);
                                        } else {
                                          return const Divider(
                                            color: AppColors.lightGrey,
                                            thickness: 2.5,
                                          );
                                        }
                                      }),
                                    ],
                                  ),
                              ],
                            ),

                            /*Column(
                              children: [
                                if(comments.isNotEmpty)...[
                                  SubTitle(text: LocalizationService().get('comments')),
                                  ListView.separated(
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(), // Prevents nested scroll issues
                                    itemCount: comments.length,
                                    itemBuilder: (context, index) {
                                      return CommentCard(comment: comments[index], isChapterShowing: true);
                                    },
                                    separatorBuilder: (context, index) {
                                      return const Divider(
                                        color: AppColors.lightGrey, // Customize the color as needed
                                        thickness: 2.5, // Customize the thickness as needed
                                      );
                                    },
                                  ),
                                ],
                                if(answers.isNotEmpty)...[
                                  const Divider(
                                    color: AppColors.lightGrey, // Customize the color as needed
                                    thickness: 2.5, // Customize the thickness as needed
                                  ),
                                  SubTitle(text: LocalizationService().get('answers')),
                                  ListView.separated(
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(), // Prevents nested scroll issues
                                    itemCount: answers.length,
                                    itemBuilder: (context, index) {
                                      return AnswerCard(answer: answers[index]);
                                    },
                                    separatorBuilder: (context, index) {
                                      return const Divider(
                                        color: AppColors.lightGrey, // Customize the color as needed
                                        thickness: 2.5, // Customize the thickness as needed
                                      );
                                    },
                                  ),
                                ]
                              ],
                            )*/
                      ));
                    },
                  ),
                ],
              );
            },
          )
      )
    );
  }
}
