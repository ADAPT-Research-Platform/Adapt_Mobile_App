import 'package:flutter/material.dart';

class SnackBarShower {

  static void _showSnackBar(GlobalKey<ScaffoldMessengerState> scaffold, String message, Color backgroundColor) {
    // Ensure scaffold is mounted
    if (scaffold.currentState != null) {
      scaffold.currentState!.showSnackBar(
        SnackBar(
            content: Text(message),
            duration: const Duration(milliseconds: 2000),
            backgroundColor: backgroundColor
        ),
      );
    }
  }

  static void info(GlobalKey<ScaffoldMessengerState> scaffold, String message) {
    _showSnackBar(scaffold, message, const Color(0xFFFEC63D));
  }

  static void warn(GlobalKey<ScaffoldMessengerState> scaffold, String message) {
    _showSnackBar(scaffold, message, const Color(0xFFA08030));
  }

  static void error(GlobalKey<ScaffoldMessengerState> scaffold, String message) {
    _showSnackBar(scaffold, message, Colors.redAccent);
  }
}