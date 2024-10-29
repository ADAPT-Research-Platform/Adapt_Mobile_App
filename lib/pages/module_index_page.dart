import 'package:adapt/models/exercise.dart';
import 'package:adapt/utils/navigator_keys.dart';
import 'package:flutter/material.dart';

import '../models/module.dart';
import '../utils/app_routes.dart';
import 'exercise_page.dart';
import 'modules_page.dart';
import 'overview_page.dart';

class ModuleIndexPage extends StatelessWidget {
  const ModuleIndexPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Navigator(
        key: moduleNavigatorKey,
        onGenerateRoute: (RouteSettings settings) {
          switch (settings.name) {
            case Routes.beehiveOverview:
              return MaterialPageRoute(
                builder: (context) => const OverviewPage(),
              );
            case Routes.beehiveModules:
              return MaterialPageRoute(
                builder: (context) => ModulePage(module: settings.arguments! as Module),
              );
            case Routes.beehiveExercises:
              return MaterialPageRoute(
                builder: (context) => ExercisePage(exercise: settings.arguments! as Exercise),
              );
            default:
              return MaterialPageRoute(
                builder: (context) => const OverviewPage(),
              );
          }
        });
  }
}
