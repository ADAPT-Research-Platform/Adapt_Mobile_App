import 'package:adapt/services/comment_service.dart';
import 'package:adapt/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

import '../models/comment.dart';
import '../utils/app_font_sizes.dart';
import '../widgets/comment_card.dart';
import '../widgets/main_title.dart';

class DiaryPage extends StatefulWidget {
  const DiaryPage({super.key});

  @override
  _DiaryPage createState() => _DiaryPage();
}

class _DiaryPage extends State<DiaryPage> {
  late DateTime _selectedDay;
  late DateTime _focusedDay;
  final CommentService _commentService = CommentService();

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
    _focusedDay = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MainTitle(title: 'Diary'),
      body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Column(
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
                      print("Selected date: $selectedDay");
                    });
                  },
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
              FutureBuilder<List<Comment>>(
                future: _commentService.fetchComments(date: _selectedDay),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(color: AppColors.darkYellow));
                  } else if (snapshot.hasError) {
                    return const Center(child: Text("Error loading comments"));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text("No comments available"));
                  }

                  final List<Comment> comments = snapshot.data!;

                  return Expanded(
                    child: ListView.separated(
                      itemCount: comments.length,
                      itemBuilder: (context, index) {
                        return CommentCard(comment: comments[index]);
                      },
                      separatorBuilder: (context, index) {
                        return const Divider(
                          color: AppColors.lightGrey, // Customize the color as needed
                          thickness: 2.5, // Customize the thickness as needed
                        );
                      },
                    ),
                  );
                },
              ),
            ],
          )),
    );
  }
}
