import 'package:adapt/pages/settings_page.dart';
import 'package:adapt/utils/app_keys.dart';
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
        key: bottomNavigator,
        onGenerateRoute: (RouteSettings settings) {
          switch (settings.name) {
            case Routes.routeOverview:
              return MaterialPageRoute(
                builder: (context) => ModuleIndexPage(),
              );
            case Routes.routeDiary:
              return MaterialPageRoute(
                builder: (context) => DiaryPage(),
              );
            case Routes.routeMode:
              return MaterialPageRoute(
                builder: (context) => ModePage(),
              );
            case Routes.routeContact:
              return MaterialPageRoute(
                builder: (context) => ContactPage(),
              );
            case Routes.routeSettings:
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
