import 'package:adapt/utils/app_keys.dart';
import 'package:flutter/material.dart';

import '../services/localization_service.dart';
import '../utils/app_colors.dart';
import 'hexagon_shape.dart';

class BottomNavBar extends StatefulWidget {
  final int currentIndex;
  final ValueChanged<int> onDestinationSelected;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onDestinationSelected
  });

  @override
  State<BottomNavBar> createState() => _AppNavigationBar();
}

class _AppNavigationBar extends State<BottomNavBar> {
  int currentPageIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 4),
      margin: const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 8.0),
      decoration: const BoxDecoration(
          color: Colors.transparent,
          border: Border(top: BorderSide(color: AppColors.lightGrey, width: 2.5))
      ),
      child: NavigationBar(
        key: bottomNavigator,
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
            selectedIcon: _buildHexagonButton(Icons.home_rounded, true),
            icon: _buildHexagonButton(Icons.home_rounded, false),
            label: LocalizationService().get('overview'),
          ),
          NavigationDestination(
            selectedIcon: _buildHexagonButton(Icons.book_rounded, true),
            icon: _buildHexagonButton(Icons.book_rounded, false),
            label: LocalizationService().get('diary'),
          ),
          NavigationDestination(
            selectedIcon: _buildHexagonButton(Icons.emoji_emotions, true),
            icon: _buildHexagonButton(Icons.emoji_emotions, false),
            label: LocalizationService().get('mood'),
          ),
          NavigationDestination(
            selectedIcon: _buildHexagonButton(Icons.account_box_rounded, true),
            icon: _buildHexagonButton(Icons.account_box_rounded, false),
            label: LocalizationService().get('support'),
          ),
          NavigationDestination(
            selectedIcon: _buildHexagonButton(Icons.settings, true),
            icon: _buildHexagonButton(Icons.settings, false),
            label: LocalizationService().get('settings'),
          ),
        ],
      ),
    );
  }

  Widget _buildHexagonButton(IconData icon, bool isSelected) {
    return HexagonShape(
        size: 65,
        fillColor: isSelected ? AppColors.primaryYellow : AppColors.white,
        strokeColor: AppColors.darkYellow,
        strokeWidth: 2.2,
        strokeRadius: 8,
        icon: icon,
        iconColor: isSelected ? AppColors.white : AppColors.primaryYellow
    );
  }
}
