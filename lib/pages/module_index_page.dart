import 'dart:io';

import 'package:adapt/models/chapter.dart';
import 'package:adapt/utils/app_keys.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logging/logging.dart';

import '../services/localization_service.dart';
import '../utils/app_routes.dart';
import 'chapter_page.dart';
import 'module_page.dart';
import 'overview_page.dart';

class ModuleIndexPage extends StatefulWidget {
  final VoidCallback reloadModePage;

  const ModuleIndexPage({super.key, required this.reloadModePage});

  @override
  _ModuleIndexPageState createState() => _ModuleIndexPageState();
}

class _ModuleIndexPageState extends State<ModuleIndexPage> {
  final log = Logger('ModuleIndexPage');
  bool _isReadyToExit = false;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, dynamic result) {
        if (didPop) {
          return;
        }

        if (_isReadyToExit) {
          SystemNavigator.pop();
        } else {
          setState(() {
            _isReadyToExit = true;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(LocalizationService().get('press_back_again_to_exit')),
              duration: const Duration(seconds: 2),
            ),
          );

          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) {
              setState(() {
                _isReadyToExit = false;
              });
            }
          });
        }
      },
      child: Navigator(
          key: moduleNavigator,
          onGenerateRoute: (RouteSettings settings) {
            switch (settings.name) {
              case Routes.routeOverview:
                return MaterialPageRoute(
                  builder: (context) => OverviewPage(reloadModePage: widget.reloadModePage),
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
                  builder: (context) => OverviewPage(reloadModePage: widget.reloadModePage),
                );
            }
          }),
    );
  }
}
