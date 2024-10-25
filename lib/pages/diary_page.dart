import 'package:flutter/material.dart';

import '../widgets/app_title_bar.dart';

class DiaryPage extends StatelessWidget {
  const DiaryPage({super.key});


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppTitleBar(title: 'Diary'),
      body: Center(child: Text('Diary Page')),
    );
  }
}
