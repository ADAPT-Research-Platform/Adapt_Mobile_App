import 'package:flutter/material.dart';

import '../utils/app_colors.dart';

class AppTitleBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final IconData? leadingIcon;
  final VoidCallback? onIconPressed;

  const AppTitleBar({
    super.key,
    required this.title,
    this.leadingIcon,
    this.onIconPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 4),
      margin: const EdgeInsets.all(8.0),
      decoration: const BoxDecoration(
        color: Colors.transparent,
        border: Border(
          bottom: BorderSide(
            color: AppColors.lightGrey, // Line color
            width: 2.5, // Line thickness
          ),
        ),
      ),
      child: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0, // Remove shadow
        leading: IconButton(
          icon: Icon(leadingIcon, color: AppColors.darkYellow, size: 35), // Static color
          onPressed: onIconPressed,
        ),
        centerTitle: true,
        title: Text(
          title,
          style: TextStyle(
            color: AppColors.darkYellow, // Static text color
            fontSize: 40, // Static font size
            fontWeight: FontWeight.bold, // Static font weight
          ),
        ),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(2.0), // Adjust the height if needed
          child: Container(
            padding: EdgeInsets.only(bottom: 8.0), // Padding for the bottom line
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(90); // Adjust the height for the bottom line
}
