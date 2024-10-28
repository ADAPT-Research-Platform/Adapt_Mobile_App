import 'package:flutter/material.dart';

import '../pages/modules_page.dart';
import '../services/firebase_module_service.dart';
import 'hexagon_shape.dart';

class ModuleGrid extends StatelessWidget {
  final int? count;
  final double size;
  final Color fillColor;
  final Color strokeColor;
  final double strokeWidth;
  final double strokeRadius;
  final IconData? icon;
  final Color? iconColor;
  final FirebaseModuleService _firebaseModuleService = FirebaseModuleService();

  ModuleGrid({
    super.key,
    this.count,
    required this.size,
    required this.fillColor,
    this.strokeColor = Colors.transparent,
    this.strokeWidth = 0,
    this.strokeRadius = 0,
    this.icon,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _firebaseModuleService.getModules(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text("Error loading modules"));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text("No modules available"));
        }

        final modules = snapshot.data!;

        return GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            mainAxisSpacing: 4,
            crossAxisSpacing: 4,
          ),
          itemCount:
              count != null && count! < modules.length ? count : modules.length,
          itemBuilder: (context, index) {
            final module = modules[index];
            final moduleId = module['id'];
            return GestureDetector(
              onTap: () {
                // Navigate to the details page with the module ID
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ModuleDetailPage(moduleId: moduleId),
                  ),
                );
              },
              child: HexagonShape(
                size: size,
                fillColor: fillColor,
                strokeColor: strokeColor,
                strokeWidth: strokeWidth,
                strokeRadius: strokeRadius,
                icon: icon,
                iconColor: iconColor,
              ),
            );
          },
        );
      },
    );
  }
}
