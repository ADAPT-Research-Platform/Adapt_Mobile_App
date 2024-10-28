import 'dart:math';

import 'package:flutter/material.dart';
import '../services/firebase_module_service.dart';
import 'hexagon_shape.dart';

//THis is just a experiment class with clickable hexagon shapes
class ModuleGrid extends StatelessWidget {
  final int count;
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
    required this.count,
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
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4, // Adjust as needed
        mainAxisSpacing: 4,
        crossAxisSpacing: 4,
      ),
      itemCount: count,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () {
            print("Hexagon clicked at index: $index");
            _firebaseModuleService.getModuleById("module_0$index");
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
  }
}
