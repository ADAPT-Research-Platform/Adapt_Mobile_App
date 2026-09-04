import 'dart:ui';

import 'package:adapt/pages/settings_page.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

import '../enums/theme_type.dart';
import '../services/auth_service.dart';
import '../utils/app_keys.dart';
import '../widgets/bottom_nav_bar.dart';
import 'diary_page.dart';
import 'mode_page.dart';
import 'module_index_page.dart';
import 'support_page.dart';

class MainPage extends StatefulWidget {
  final Function(ThemeType) onThemeChanged;

  const MainPage({super.key, required this.onThemeChanged});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> with WidgetsBindingObserver {
  final log = Logger('MainPage');
  final AuthService _authService = AuthService();

  int _currentIndex = 0;
  bool shouldReloadModePage = false;

  // Track the session start time (or other session info) if needed.
  DateTime? _sessionStart;

  // The function to reload ModePage
  void reloadModePage() {
    setState(() {
      shouldReloadModePage = true; // Flag that we need to reload ModePage
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _sessionStart = DateTime.now();
    log.info("AppLifecycleState: started: ${DateTime.now()}");
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused
        || state == AppLifecycleState.inactive
        || state == AppLifecycleState.detached){
      log.info("AppLifecycleState: paused: ${DateTime.now()}");
      _authService.track(_sessionStart, DateTime.now());
    }else if (state == AppLifecycleState.resumed){
      _sessionStart = DateTime.now();
      log.info("AppLifecycleState: resumed: ${DateTime.now()}");
    }
  }

  @override
  Future<AppExitResponse> didRequestAppExit() async {
    log.info("AppLifecycleState: exited: ${DateTime.now()}");
    return AppExitResponse.exit;
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
              SupportPage(),
              SettingsPage(onThemeChanged: widget.onThemeChanged),
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
