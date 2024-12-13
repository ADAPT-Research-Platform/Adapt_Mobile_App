import 'package:flutter/material.dart';

import '../utils/app_colors.dart';
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
      this.backgroundColor = AppColors.primaryYellow,
      this.icon
  });

  @override
  Widget build(BuildContext context) {
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
        minimumSize: const Size(double.infinity, 50), // Full-width button
        foregroundColor: AppColors.white,
        backgroundColor: backgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
        ),
      ),
    );
  }
}
