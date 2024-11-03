import 'package:adapt/widgets/module_grid.dart';
import 'package:flutter/material.dart';

import '../models/module.dart';
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

  final FirebaseModuleService _firebaseModuleService = FirebaseModuleService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppTitleBar(title: 'Overview'),
      body: FutureBuilder<List<Module>>(
        future: _firebaseModuleService.fetchModuleList(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppColors.darkYellow));
          } else if (snapshot.hasError) {
            return const Center(child: Text("Error loading modules"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No modules available"));
          }

          final modules = snapshot.data!;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
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
                  child: SizedBox(
                    height: 300,
                    child: ModuleGrid(
                      modules: modules,
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
                child: const Text(
                  'Continue',
                  style: TextStyle(
                    fontSize: AppFontSizes.small,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Divider(
                color: AppColors.lightGrey, // Customize the color as needed
                thickness: 2.5, // Customize the thickness as needed
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
          );
        },
      )
    );
  }
}
