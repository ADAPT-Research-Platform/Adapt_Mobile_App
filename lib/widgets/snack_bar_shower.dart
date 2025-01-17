import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

class SnackBarShower {
  static void _showSnackBar(GlobalKey<ScaffoldMessengerState> scaffold, String message, Color backgroundColor) {
    print(message);
    // Ensure scaffold is mounted
    if (scaffold.currentState != null) {
      scaffold.currentState!.showSnackBar(
        SnackBar(content: Text(message), backgroundColor: backgroundColor),
      );
    }
  }

  static void info(GlobalKey<ScaffoldMessengerState> scaffold, String message) {
    _showSnackBar(scaffold, message, AppColors.primaryYellow);
  }

  static void warn(GlobalKey<ScaffoldMessengerState> scaffold, String message) {
    _showSnackBar(scaffold, message, AppColors.darkYellow);
  }

  static void error(GlobalKey<ScaffoldMessengerState> scaffold, String message) {
    _showSnackBar(scaffold, message, Colors.redAccent);
  }
}