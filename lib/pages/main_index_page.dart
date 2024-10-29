import 'package:adapt/pages/settings_page.dart';
import 'package:adapt/utils/navigator_keys.dart';
import 'package:flutter/material.dart';

import '../utils/app_routes.dart';
import 'contact_page.dart';
import 'diary_page.dart';
import 'mode_page.dart';
import 'module_index_page.dart';
import 'overview_page.dart';

class MainIndexPage extends StatelessWidget {
  const MainIndexPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Navigator(
        key: bottomNavigatorKey,
        onGenerateRoute: (RouteSettings settings) {
          switch (settings.name) {
            case Routes.beehiveOverview:
              return MaterialPageRoute(
                builder: (context) => ModuleIndexPage(),
              );
            case Routes.beehiveDiary:
              return MaterialPageRoute(
                builder: (context) => DiaryPage(),
              );
            case Routes.beehiveMode:
              return MaterialPageRoute(
                builder: (context) => ModePage(),
              );
            case Routes.beehiveContact:
              return MaterialPageRoute(
                builder: (context) => ContactPage(),
              );
            case Routes.beehiveSettings:
              return MaterialPageRoute(
                builder: (context) => SettingsPage(),
              );
            default:
              return MaterialPageRoute(
                builder: (context) => OverviewPage(),
              );
          }
        });
  }
}
