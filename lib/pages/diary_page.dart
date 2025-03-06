import 'package:adapt/services/chapter_service.dart';
import 'package:adapt/services/comment_service.dart';
import 'package:adapt/services/module_service.dart';
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
                return Center(child: CircularProgressIndicator(color: Theme.of(context).primaryColorDark));
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
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Theme.of(context).primaryColorDark, // Border color
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
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Theme.of(context).primaryColorLight,
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
                      headerStyle: HeaderStyle(
                        formatButtonVisible: false, // Hide the "2 weeks" button
                        titleCentered: true, // Center the header text
                        headerPadding: const EdgeInsets.symmetric(vertical: 0.0),
                        leftChevronIcon: Icon(Icons.arrow_back_ios_rounded, color: Theme.of(context).primaryColorDark, size: 32),
                        rightChevronIcon: Icon(Icons.arrow_forward_ios_rounded, color: Theme.of(context).primaryColorDark, size: 32),
                        titleTextStyle: TextStyle(
                          color: Theme.of(context).primaryColorDark, // Static text color
                          fontSize: AppFontSizes.medium, // Static font size
                          fontWeight: FontWeight.bold, // Static font weight
                        ),
                      ),
                      calendarStyle: CalendarStyle(
                        //tablePadding: EdgeInsets.fromLTRB(0, 0, 0, 15),
                        cellMargin: const EdgeInsets.all(4.0),
                        todayDecoration: BoxDecoration(
                          color: Theme.of(context).primaryColorDark,
                          shape: BoxShape.circle,
                        ),
                        selectedDecoration: const BoxDecoration(
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
                        return Center(child: CircularProgressIndicator(color: Theme.of(context).primaryColorDark));
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
                                    iconColor: Theme.of(context).primaryColorDark,
                                    collapsedIconColor: Theme.of(context).primaryColorDark,
                                    children: [
                                      ...List.generate(comments.length * 2 - 1, (index) {
                                        if (index.isEven) {
                                          return CommentCard(comment: comments[index ~/ 2], isChapterShowing: true, isEnableReply: false);
                                        } else {
                                          return Divider(
                                            color: Theme.of(context).dividerColor,
                                            thickness: 2.5,
                                          );
                                        }
                                      }),
                                    ],
                                  ),
                                if (answers.isNotEmpty)
                                  ExpansionTile(
                                    title: SubTitle(text: LocalizationService().get('answers')),
                                    iconColor: Theme.of(context).primaryColorDark,
                                    collapsedIconColor: Theme.of(context).primaryColorDark,
                                    children: [
                                      ...List.generate(answers.length * 2 - 1, (index) {
                                        if (index.isEven) {
                                          return AnswerCard(answer: answers[index ~/ 2]);
                                        } else {
                                          return Divider(
                                            color: Theme.of(context).dividerColor,
                                            thickness: 2.5,
                                          );
                                        }
                                      }),
                                    ],
                                  ),
                              ],
                            ),
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
