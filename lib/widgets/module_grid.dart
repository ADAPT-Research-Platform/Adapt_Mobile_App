import 'package:adapt/utils/navigator_keys.dart';
import 'package:flutter/material.dart';

import '../models/module.dart';
import '../utils/app_routes.dart';
import 'hexagon_shape.dart';

class ModuleGrid extends StatelessWidget {
  final List<Module> modules;
  final double size;
  final Color fillColor;
  final Color strokeColor;
  final double strokeWidth;
  final double strokeRadius;
  final IconData? icon;
  final Color? iconColor;

  const ModuleGrid({
    super.key,
    required this.modules,
    required this.size,
    required this.fillColor,
    this.strokeColor = Colors.transparent,
    this.strokeWidth = 0,
    this.strokeRadius = 0,
    this.icon,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 4,
        crossAxisSpacing: 4,
      ),
      itemCount: modules.length,
      itemBuilder: (context, index) {
        final module = modules[index];
        return GestureDetector(
          onTap: () {
            moduleNavigatorKey.currentState!.pushNamed(Routes.beehiveModules, arguments: module);
          },
          child: HexagonShape(
            size: size,
            fillColor: fillColor,
            strokeColor: strokeColor,
            strokeWidth: strokeWidth,
            strokeRadius: strokeRadius,
            icon: icon,
            iconColor: iconColor,
          ),
        );
      },
    );
  }
}
