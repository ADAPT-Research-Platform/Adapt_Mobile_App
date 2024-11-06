import 'package:adapt/widgets/app_title_bar.dart';
import 'package:flutter/material.dart';

import '../models/mode.dart';
import '../services/firebase_mode_service.dart';
import '../utils/app_colors.dart';
import '../utils/app_font_sizes.dart';
import '../widgets/feeling_chart.dart';
import '../widgets/motivation_chart.dart';

class ModePage extends StatefulWidget {
  const ModePage({super.key});

  @override
  _ModePageState createState() => _ModePageState();
}

class _ModePageState extends State<ModePage> {
  final ScrollController _scrollController = ScrollController();
  final FirebaseModeService _firebaseModeService = FirebaseModeService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppTitleBar(title: 'Mode'),
        body: FutureBuilder<List<Mode>>(
            future: _firebaseModeService.fetchModeList('xZOnZ2mQvTWTObfryho7tbetU1V2'),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: AppColors.darkYellow));
              } else if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text("Error loading mode tracking data"));
              }

              final modeData = snapshot.data!;

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Column(
                  children: [
                    const Center(
                      child: Text(
                        'Feeling',
                        style: TextStyle(
                          color: AppColors.darkYellow, // Static text color
                          fontSize: AppFontSizes.medium, // Static font size
                          fontWeight: FontWeight.bold, // Static font weight
                        ),
                      ),
                    ),
                    Expanded(
                      child: FeelingChart(modeData: modeData),
                    ),
                    const Divider(
                      color: AppColors.lightGrey,
                      // Customize the color as needed
                      thickness: 2.5, // Customize the thickness as needed
                    ),
                    const Center(
                      child: Text(
                        'Motivation',
                        style: TextStyle(
                          color: AppColors.darkYellow, // Static text color
                          fontSize: AppFontSizes.medium, // Static font size
                          fontWeight: FontWeight.bold, // Static font weight
                        ),
                      ),
                    ),
                    Expanded(
                      child: MotivationChart(modeData: modeData),
                    ),
                  ],
                ),
              );
            }));
  }
}