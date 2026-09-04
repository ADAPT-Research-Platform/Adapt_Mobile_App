import 'package:flutter/material.dart';

import '../services/localization_service.dart';

class SnackBarShower {

  static void _showSnackBar(GlobalKey<ScaffoldMessengerState> scaffold, String message, Color backgroundColor, Color fontColor) {
    // Ensure scaffold is mounted
    if (scaffold.currentState != null) {
      scaffold.currentState!.showSnackBar(
        SnackBar(
            content: Text(
                LocalizationService().get(message), 
                style: TextStyle(color: fontColor)
            ),
            duration: const Duration(milliseconds: 2000),
            backgroundColor: backgroundColor
        ),
      );
    }
  }

  static void info(GlobalKey<ScaffoldMessengerState> scaffold, String message) {
    _showSnackBar(scaffold, message, const Color(0xFFA08030), const Color(0xFFFEC63D));
  }

  static void warn(GlobalKey<ScaffoldMessengerState> scaffold, String message) {
    _showSnackBar(scaffold, message, const Color(0xFFA08030), const Color(0XFF5252FF));
  }

  static void error(GlobalKey<ScaffoldMessengerState> scaffold, String message) {
    _showSnackBar(scaffold, message, const Color(0XFF5252FF), const Color(0xFFA08030));
  }
}