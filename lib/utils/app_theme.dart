import 'package:flutter/material.dart';

class AppTheme {

  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColorLight: const Color(0xFFFEC63D), // primaryYellow
    primaryColorDark: const Color(0xFFA08030),  // darkYellow

    indicatorColor: const Color(0XFFFFE04A),    // paleYellow
    scaffoldBackgroundColor: const Color(0xFFFFFFFF),
    cardColor: const Color(0xFFF0EBEB),
    highlightColor: const Color(0xFFD1C8C8),    // Dark Grey
    disabledColor: const Color(0xFFEDE9E1),     // Light Grey
    dividerColor: const Color(0xFFEDE9E1),      // Light Grey
    textTheme: const TextTheme(
      displayLarge: TextStyle(color: Color(0xFF464646)),
    ),
  );

  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColorLight: const Color(0xFFFEC63D), // primaryYellow
    primaryColorDark: const Color(0xFFA08030),  // darkYellow

    indicatorColor: const Color(0XFFFCA932),
    scaffoldBackgroundColor: const Color(0xFF464646),
    cardColor: const Color(0xFF404040),
    highlightColor: const Color(0xFF343434),    // Dark Grey
    disabledColor: const Color(0xFF525252),
    dividerColor: const Color(0xFF525252),
    textTheme: const TextTheme(
      displayLarge: TextStyle(color: Color(0xFFF0EBEB)),
    ),
  );
}
