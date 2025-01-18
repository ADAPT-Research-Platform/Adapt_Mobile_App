import 'package:adapt/pages/settings_page.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

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
  final log = Logger('MainPage');

  int _currentIndex = 0;
  bool shouldReloadModePage = false;

  // The function to reload ModePage
  void reloadModePage() {
    setState(() {
      shouldReloadModePage = true; // Flag that we need to reload ModePage
      //_currentIndex = 1; // Switch to the ModePage
    });
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      key: mainPageScaffold,
      child: Scaffold(
          body: IndexedStack(
            index: _currentIndex,
            children: [
              ModuleIndexPage(reloadModePage: reloadModePage),
              const DiaryPage(),
              ModePage(shouldReload: shouldReloadModePage),
              ContactPage(),
              const SettingsPage(),
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
