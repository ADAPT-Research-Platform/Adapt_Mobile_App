import 'package:adapt/widgets/module_grid.dart';
import 'package:flutter/material.dart';

import '../services/firebase_module_service.dart';
import '../utils/app_colors.dart';
import '../utils/app_font_sizes.dart';
import '../widgets/app_title_bar.dart';

class OverviewPage extends StatefulWidget {
  const OverviewPage({super.key});

  @override
  _OverviewPageState createState() => _OverviewPageState();
}

class _OverviewPageState extends State<OverviewPage> {
  int _moduleCount = 0;

  final FirebaseModuleService _firebaseModuleService = FirebaseModuleService();

  @override
  void initState() {
    super.initState();
    _fetchModuleCount();
  }

  Future<void> _fetchModuleCount() async {
    try {
      final count = await _firebaseModuleService.getModuleCount();
      setState(() {
        _moduleCount = count;
      });
    } catch (e) {
      // Handle any errors here
      print('Error fetching module count: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppTitleBar(title: 'Overview'),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0),
        child: ListView(children: [
          const Center(
            child: Text(
              'Progress',
              style: TextStyle(
                color: AppColors.darkYellow, // Static text color
                fontSize: AppFontSizes.medium, // Static font size
                fontWeight: FontWeight.bold, // Static font weight
              ),
            ),
          ),
          Center(
              child: Container(
            height: 300,
            child: ModuleGrid(
              size: 100,
              fillColor: AppColors.primaryYellow,
              strokeColor: AppColors.white,
              strokeWidth: 6,
              icon: Icons.play_arrow_rounded,
              iconColor: AppColors.darkYellow,
            ),
          )),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              foregroundColor: AppColors.white,
              backgroundColor: AppColors.primaryYellow,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6.0),
              ),
              minimumSize: Size(double.infinity, 50),
            ),
            child: Text(
              'Continue',
              style: const TextStyle(
                fontSize: AppFontSizes.small,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.only(bottom: 10),
            decoration: const BoxDecoration(
              color: Colors.transparent,
              border: Border(
                  bottom: BorderSide(color: AppColors.lightGrey, width: 2.5)),
            ),
          ),
          const Center(
            child: Text(
              'Everyday Questions',
              style: TextStyle(
                color: AppColors.darkYellow, // Static text color
                fontSize: AppFontSizes.medium, // Static font size
                fontWeight: FontWeight.bold, // Static font weight
              ),
            ),
          ),
        ]),
      ),
    );
  }
}
