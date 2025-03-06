import 'package:flutter/material.dart';

import '../utils/app_font_sizes.dart';

class TaskButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final IconData? icon;

  const TaskButton({
      super.key,
      required this.text,
      this.onPressed,
      this.backgroundColor,
      this.icon
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: icon != null ? Icon(icon, size: 18) : null,
      label: Text(
        text,
        style: const TextStyle(
          fontSize: AppFontSizes.small,
        ),
      ),
      style: ElevatedButton.styleFrom(
        minimumSize: Size(screenWidth / 2, 50), // Full-width button
        foregroundColor: Theme.of(context).scaffoldBackgroundColor,
        backgroundColor: backgroundColor ?? Theme.of(context).primaryColorLight,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
        ),
      ),
    );
  }
}
