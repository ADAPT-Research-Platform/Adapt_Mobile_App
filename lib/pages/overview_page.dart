import 'package:flutter/material.dart';

import '../utils/app_colors.dart';
import '../widgets/app_title_bar.dart';
import '../widgets/hexagon_grid.dart';

class OverviewPage extends StatelessWidget {
  const OverviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: AppTitleBar(title: 'Overview'),
      body: Center(
          child: HexagonGrid(
        rows: 6,
        cols: 2,
        size: 110,
        fillColor: AppColors.primaryYellow,
        strokeColor: AppColors.white,
        strokeWidth: 6,
        icon: Icons.play_arrow_rounded,
            iconColor: AppColors.darkYellow,
      )),
    );
  }
}
