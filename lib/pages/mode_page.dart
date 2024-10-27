import 'package:adapt/widgets/app_title_bar.dart';
import 'package:flutter/material.dart';

class ModePage extends StatelessWidget {
  const ModePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppTitleBar(title: 'Mode'),
      body: Center(child: Text('Mode Page')),
    );
  }
}