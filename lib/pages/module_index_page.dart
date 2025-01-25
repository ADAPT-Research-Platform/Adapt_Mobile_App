import 'package:adapt/models/chapter.dart';
import 'package:adapt/utils/app_keys.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

import '../utils/app_routes.dart';
import 'chapter_page.dart';
import 'overview_page.dart';
import 'section_page.dart';

class ModuleIndexPage extends StatelessWidget {
  final log = Logger('ModuleIndexPage');

  final VoidCallback reloadModePage;

  ModuleIndexPage({super.key, required this.reloadModePage});

  @override
  Widget build(BuildContext context) {
    return Navigator(
        key: moduleNavigator,
        onGenerateRoute: (RouteSettings settings) {
          switch (settings.name) {
            case Routes.routeOverview:
              return MaterialPageRoute(
                builder: (context) => OverviewPage(reloadModePage: reloadModePage),
              );
            case Routes.routeChapters:
              return MaterialPageRoute(
                builder: (context) => ChapterPage(moduleId: settings.arguments! as String),
              );
            case Routes.routeSections:
              return MaterialPageRoute(
                builder: (context) => SectionPage(section: settings.arguments! as Chapter),
              );
            default:
              return MaterialPageRoute(
                builder: (context) => OverviewPage(reloadModePage: reloadModePage),
              );
          }
        });
  }
}
