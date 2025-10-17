import 'package:adapt/utils/app_keys.dart';
import 'package:flutter/material.dart';

import '../services/localization_service.dart';
import '../utils/app_routes.dart';
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
  double margin = 8.0;

  double _getMaxLabelWidth(BuildContext context) {
    final deviceWidth = MediaQuery.of(context).size.width;
    return (deviceWidth - (margin * 2)) / 5.5;
  }

  @override
  Widget build(BuildContext context) {

    return Container(
      padding: const EdgeInsets.only(top: 4),
      margin: EdgeInsets.fromLTRB(margin, 0.0, margin, margin),
      decoration: BoxDecoration(
          color: Colors.transparent,
          border: Border(top: BorderSide(color: Theme.of(context).dividerColor, width: 2.5))
      ),
      child: NavigationBar(
        key: bottomNavigator,
        onDestinationSelected: (index) {
          widget.onDestinationSelected(index);
          setState(() {
            if(currentPageIndex == 0 && index == 0){
              moduleNavigator.currentState!.pushNamed(Routes.routeOverview);
            }

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
            label: truncate(LocalizationService().get('overview')),
          ),
          NavigationDestination(
            selectedIcon: _buildHexagonButton(Icons.book_rounded, true),
            icon: _buildHexagonButton(Icons.book_rounded, false),
            label: truncate(LocalizationService().get('diary')),
          ),
          NavigationDestination(
            selectedIcon: _buildHexagonButton(Icons.emoji_emotions, true),
            icon: _buildHexagonButton(Icons.emoji_emotions, false),
            label: truncate(LocalizationService().get('mood')),
          ),
          NavigationDestination(
            selectedIcon: _buildHexagonButton(Icons.account_box_rounded, true),
            icon: _buildHexagonButton(Icons.account_box_rounded, false),
            label: truncate(LocalizationService().get('support')),
          ),
          NavigationDestination(
            selectedIcon: _buildHexagonButton(Icons.settings, true),
            icon: _buildHexagonButton(Icons.settings, false),
            label: truncate(LocalizationService().get('settings')),
          ),
        ],
      ),
    );
  }

  Widget _buildHexagonButton(IconData icon, bool isSelected) {
    return HexagonShape(
        size: 65,
        fillColor: isSelected ? Theme.of(context).primaryColorLight : Theme.of(context).scaffoldBackgroundColor,
        strokeColor: Theme.of(context).primaryColorDark,
        strokeWidth: 2.2,
        strokeRadius: 8,
        icon: icon,
        iconColor: isSelected ? Theme.of(context).scaffoldBackgroundColor : Theme.of(context).primaryColorLight
    );
  }

  String truncate(String text) {
    double maxWidth = _getMaxLabelWidth(context);

    final textPainter = TextPainter(
      text: TextSpan(text: text),
      maxLines: 1,
      textDirection: TextDirection.ltr,
      textScaler: MediaQuery.textScalerOf(context), // Use textScalerOf for modern Flutter
    )..layout(minWidth: 0, maxWidth: maxWidth);

    if (textPainter.didExceedMaxLines || textPainter.width > maxWidth) {
      // Find the position to truncate
      int endIndex = text.length - 1;
      while (endIndex > 0) {
        final truncatedText = '${text.substring(0, endIndex)}..';
        final tempPainter = TextPainter(
          text: TextSpan(text: truncatedText),
          maxLines: 1,
          textDirection: TextDirection.ltr,
          textScaler: MediaQuery.textScalerOf(context),
        )..layout(minWidth: 0, maxWidth: maxWidth);

        if (tempPainter.width < maxWidth) {
          return truncatedText;
        }
        endIndex--;
      }
      return "..."; // Fallback if even "..." is too long
    }
    return text;
  }
}
