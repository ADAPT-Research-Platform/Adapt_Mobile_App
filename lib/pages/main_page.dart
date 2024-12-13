import 'package:adapt/pages/settings_page.dart';
import 'package:adapt/utils/app_colors.dart';
import 'package:flutter/material.dart';

import '../utils/app_keys.dart';
import '../widgets/bottom_nav_bar.dart';
import 'contact_page.dart';
import 'diary_page.dart';
import 'mode_page.dart';
import 'module_index_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      key: mainPageScaffold,
      child: Scaffold(
          body: IndexedStack(
            index: _currentIndex,
            children: const [
              ModuleIndexPage(),
              DiaryPage(),
              ModePage(),
              ContactPage(),
              SettingsPage(),
            ],
          ),
          bottomNavigationBar: BottomNavBar(
            currentIndex: _currentIndex,
            onDestinationSelected: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
          )),
    );
  }
}
