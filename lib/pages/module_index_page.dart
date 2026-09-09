import 'package:flutter/material.dart';

import '../models/chapter.dart';
import '../utils/app_keys.dart';
import '../utils/app_routes.dart';
import 'chapter_page.dart';
import 'module_page.dart';
import 'overview_page.dart';

class ModuleIndexPage extends StatelessWidget {
  final VoidCallback reloadModePage;

  const ModuleIndexPage({
    super.key,
    required this.reloadModePage,
  });

  @override
  Widget build(BuildContext context) {
    return NavigatorPopHandler(
      onPop: () {
        moduleNavigator.currentState?.maybePop();
      },
      child: Navigator(
        key: moduleNavigator,
        onGenerateRoute: (RouteSettings settings) {
          switch (settings.name) {
            case Routes.routeOverview:
              return MaterialPageRoute(
                builder: (context) => OverviewPage(reloadModePage: reloadModePage),
              );
            case Routes.routeChapters:
              return MaterialPageRoute(
                builder: (context) => ModulePage(moduleId: settings.arguments! as String),
              );
            case Routes.routeSections:
              final args = settings.arguments as Map<String, dynamic>;
              final section = args['section'] as Chapter;
              final moduleId = args['moduleId'] as String;
              return MaterialPageRoute(
                builder: (context) => ChapterPage(section: section, moduleId: moduleId),
              );
            default:
              return MaterialPageRoute(
                builder: (context) => OverviewPage(reloadModePage: reloadModePage),
              );
          }
        },
      ),
    );
  }
}
