import 'dart:math';

import 'package:adapt/utils/app_colors.dart';
import 'package:flutter/material.dart';

import '../models/module.dart';
import '../utils/app_routes.dart';
import '../utils/app_keys.dart';
import 'hexagon_shape.dart';

class ModuleGrid extends StatelessWidget {
  final List<Module> modules;
  final double size;
  final Color fillColor;
  final Color strokeColor;
  final double strokeWidth;
  final double strokeRadius;
  final IconData icon;
  final Color iconColor;

  const ModuleGrid({
    super.key,
    required this.modules,
    required this.size,
    this.fillColor = AppColors.primaryYellow,
    this.strokeColor = AppColors.darkYellow,
    this.strokeWidth = 1.4,
    this.strokeRadius = 5,
    this.icon = Icons.play_arrow_rounded,
    this.iconColor = AppColors.darkYellow,
  });

  @override
  Widget build(BuildContext context) {
    int gapSize = 3;
    return SizedBox(
      width: size * 3,
      height: size * 3,
      child: Stack(
        children: [
          Positioned(
              top: size - (size + gapSize) * cos(pi / 6) - gapSize * 2,
              left: size,
              child: _buildHexagonButton(0)),
          Positioned(
              top: size * cos(pi / 3) + gapSize,
              left: size + size * cos(pi / 6) - gapSize,
              child: _buildHexagonButton(1)),
          Positioned(
              top: size + size * cos(pi / 3) - gapSize,
              left: size + size * cos(pi / 6) - gapSize,
              child: _buildHexagonButton(2)),
          Positioned(
              top: size + (size + gapSize) * cos(pi / 6) + gapSize * 2,
              left: size,
              child: _buildHexagonButton(3)),
          Positioned(
              top: size + size * cos(pi / 3) - gapSize,
              left: size - size * cos(pi / 6) + gapSize,
              child: _buildHexagonButton(4)),
          Positioned(
              top: size * cos(pi / 3) + gapSize,
              left: size - size * cos(pi / 6) + gapSize,
              child: _buildHexagonButton(5)),
          Positioned(top: size, left: size, child: _buildHexagonButton(6)),
        ],
      ),
    );
  }

  Widget _buildHexagonButton(int index) {
    bool isIndexAvailable = index >=0 && index < modules.length;

    return GestureDetector(
        onTap: () {
          if (isIndexAvailable) {
            moduleNavigator.currentState!.pushNamed(Routes.routeModules, arguments: modules[index]);
          }else{
            print('No Module Available');
          }
        },
        child: HexagonShape(
            size: size,
            fillColor: isIndexAvailable ? AppColors.primaryYellow : AppColors.lightGrey,
            strokeColor: isIndexAvailable ? AppColors.darkYellow : AppColors.darkGrey,
            strokeWidth: strokeWidth,
            strokeRadius: strokeRadius,
            icon: icon,
            iconColor: isIndexAvailable ? AppColors.darkYellow : AppColors.darkGrey,
            iconSize: size / 1.5,
            iconText: Text(
              (index + 1).toString(),
              style: TextStyle(
                color: isIndexAvailable ? AppColors.primaryYellow : AppColors.lightGrey,
                fontSize: size / 8,
              ),
            )
        )
    );
  }
}
