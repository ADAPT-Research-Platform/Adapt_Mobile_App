import 'package:adapt/utils/navigator_keys.dart';
import 'package:flutter/material.dart';

import '../utils/app_colors.dart';
import 'hexagon_shape.dart';

class AppNavigationBar extends StatefulWidget {
  final int currentIndex;
  final ValueChanged<int> onDestinationSelected;

  const AppNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onDestinationSelected
  });

  @override
  State<AppNavigationBar> createState() => _AppNavigationBar();
}

class _AppNavigationBar extends State<AppNavigationBar> {
  int currentPageIndex = 0;
  double size = 65;
  double strokeWidth = 2.2;
  double strokeRadius = 8;
  Color fillColor = AppColors.primaryYellow;
  Color iconColor = AppColors.white;
  Color strokeColor = AppColors.darkYellow;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 4),
      margin: const EdgeInsets.all(8.0),
      decoration: const BoxDecoration(
          color: Colors.transparent,
          border:
              Border(top: BorderSide(color: AppColors.lightGrey, width: 2.5))),
      child: NavigationBar(
        key: bottomNavigatorKey,
        onDestinationSelected: (index) {
          widget.onDestinationSelected(index);
          setState(() {
            currentPageIndex = index;
          });
        },
        height: 90,
        backgroundColor: Colors.transparent,
        indicatorColor: Colors.transparent,
        selectedIndex: currentPageIndex,
        destinations: <Widget>[
          NavigationDestination(
            selectedIcon: HexagonShape(
                size: size,
                fillColor: fillColor,
                strokeColor: strokeColor,
                strokeWidth: strokeWidth,
                strokeRadius: strokeRadius,
                icon: Icons.home,
                iconColor: iconColor),
            icon: HexagonShape(
                size: size,
                fillColor: iconColor,
                strokeColor: strokeColor,
                strokeWidth: strokeWidth,
                strokeRadius: strokeRadius,
                icon: Icons.home,
                iconColor: fillColor),
            label: 'Overview',
          ),
          NavigationDestination(
            selectedIcon: HexagonShape(
                size: size,
                fillColor: fillColor,
                strokeColor: strokeColor,
                strokeWidth: strokeWidth,
                strokeRadius: strokeRadius,
                icon: Icons.book,
                iconColor: iconColor),
            icon: HexagonShape(
                size: size,
                fillColor: iconColor,
                strokeColor: strokeColor,
                strokeWidth: strokeWidth,
                strokeRadius: strokeRadius,
                icon: Icons.book,
                iconColor: fillColor),
            label: 'Diary',
          ),
          NavigationDestination(
            selectedIcon: HexagonShape(
                size: size,
                fillColor: fillColor,
                strokeColor: strokeColor,
                strokeWidth: strokeWidth,
                strokeRadius: strokeRadius,
                icon: Icons.area_chart_rounded,
                iconColor: iconColor),
            icon: HexagonShape(
                size: size,
                fillColor: iconColor,
                strokeColor: strokeColor,
                strokeWidth: strokeWidth,
                strokeRadius: strokeRadius,
                icon: Icons.area_chart_rounded,
                iconColor: fillColor),
            label: 'Mode',
          ),
          NavigationDestination(
            selectedIcon: HexagonShape(
                size: size,
                fillColor: fillColor,
                strokeColor: strokeColor,
                strokeWidth: strokeWidth,
                strokeRadius: strokeRadius,
                icon: Icons.contacts,
                iconColor: iconColor),
            icon: HexagonShape(
                size: size,
                fillColor: iconColor,
                strokeColor: strokeColor,
                strokeWidth: strokeWidth,
                strokeRadius: strokeRadius,
                icon: Icons.contacts,
                iconColor: fillColor),
            label: 'Contacts',
          ),
          NavigationDestination(
            selectedIcon: HexagonShape(
                size: size,
                fillColor: fillColor,
                strokeColor: strokeColor,
                strokeWidth: strokeWidth,
                strokeRadius: strokeRadius,
                icon: Icons.settings,
                iconColor: iconColor),
            icon: HexagonShape(
                size: size,
                fillColor: iconColor,
                strokeColor: strokeColor,
                strokeWidth: strokeWidth,
                strokeRadius: strokeRadius,
                icon: Icons.settings,
                iconColor: fillColor),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
