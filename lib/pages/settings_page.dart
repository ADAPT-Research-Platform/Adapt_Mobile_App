import 'package:adapt/widgets/app_title_bar.dart';
import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppTitleBar(title: 'Settings'),
      body: Center(child: Text('Settings Page')),
    );
  }
}
