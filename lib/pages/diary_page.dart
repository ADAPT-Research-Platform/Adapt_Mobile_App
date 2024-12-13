import 'package:adapt/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

import '../models/comment.dart';
import '../models/user.dart';
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
                    leftChevronIcon: Icon(Icons.chevron_left, color: AppColors.darkYellow, size: 32),
                    rightChevronIcon: Icon(Icons.chevron_right, color: AppColors.darkYellow, size: 32),
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
              Expanded(
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
              ),
            ],
          )),
    );
  }
}
