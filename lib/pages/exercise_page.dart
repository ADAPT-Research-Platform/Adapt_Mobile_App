import 'dart:convert';

import 'package:adapt/models/exercise.dart';
import 'package:adapt/utils/app_colors.dart';
import 'package:adapt/widgets/app_title_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:http/http.dart' as http;

import '../utils/navigator_keys.dart';

class ExercisePage extends StatefulWidget {
  final Exercise exercise;

  const ExercisePage({super.key, required this.exercise});

  @override
  _ExercisePageState createState() => _ExercisePageState();
}

class _ExercisePageState extends State<ExercisePage> {
  final ScrollController _scrollController = ScrollController();

  // Example Markdown content
  String markdownContent = "";

  @override
  void initState() {
    super.initState();
    fetchMarkdownContent();
  }

  Future<void> fetchMarkdownContent() async {
    try {
      final response = await http.get(Uri.parse(widget.exercise.content));

      if (response.statusCode == 200) {
        setState(() {
          markdownContent  = utf8.decode(response.bodyBytes, allowMalformed: true);
        });
      } else {
        throw Exception("Failed to load markdown content");
      }
    } catch (e) {
      print("Error fetching markdown content: $e");
    }
  }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppTitleBar(
          title: 'Exercise X',
          leadingIcon: Icons.arrow_back_ios,
          onIconPressed: (){
            moduleNavigatorKey.currentState!.pop();
          }),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              child: MarkdownBody(
                data: markdownContent,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back_ios,
                      color: AppColors.darkYellow, size: 25), // Static color
                  onPressed: () => _scroll(-250),
                ),
                IconButton(
                  icon: Icon(Icons.arrow_forward_ios,
                      color: AppColors.darkYellow, size: 25), // Static color
                  onPressed: () => _scroll(250),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
