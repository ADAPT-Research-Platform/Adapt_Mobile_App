import 'package:flutter/material.dart';

import '../utils/app_font_sizes.dart';

class SubTitle extends StatelessWidget {
  final String text;

  const SubTitle({
    super.key,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        text,
        style: TextStyle(
          color: Theme.of(context).primaryColorDark, // Static text color
          fontSize: AppFontSizes.medium, // Static font size
          fontWeight: FontWeight.bold, // Static font weight
        ),
      ),
    );
  }
}
