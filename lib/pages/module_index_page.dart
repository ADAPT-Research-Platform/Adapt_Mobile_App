import 'package:adapt/models/section.dart';
import 'package:adapt/utils/app_keys.dart';
import 'package:flutter/material.dart';

import '../models/module.dart';
import '../utils/app_routes.dart';
import 'section_page.dart';
import 'module_page.dart';
import 'overview_page.dart';

class ModuleIndexPage extends StatelessWidget {
  const ModuleIndexPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Navigator(
        key: moduleNavigator,
        onGenerateRoute: (RouteSettings settings) {
          switch (settings.name) {
            case Routes.routeOverview:
              return MaterialPageRoute(
                builder: (context) => const OverviewPage(),
              );
            case Routes.routeModules:
              return MaterialPageRoute(
                builder: (context) => ModulePage(module: settings.arguments! as Module),
              );
            case Routes.routeExercises:
              return MaterialPageRoute(
                builder: (context) => SectionPage(section: settings.arguments! as Section),
              );
            default:
              return MaterialPageRoute(
                builder: (context) => const OverviewPage(),
              );
          }
        });
  }
}
