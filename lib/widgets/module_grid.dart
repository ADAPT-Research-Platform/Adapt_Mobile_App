import 'dart:math';

import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

import '../services/localization_service.dart';
import '../utils/app_keys.dart';
import '../utils/app_routes.dart';
import 'hexagon_shape.dart'; // Assuming this widget just draws a hexagon of a given size

class ModuleGrid extends StatelessWidget {
  final log = Logger('ModuleGrid');
  final List<String> moduleIdList;

  // Parameters for the HexagonShape widget itself (passed through)
  final double strokeWidth;
  final double strokeRadius;
  final IconData icon;

  ModuleGrid({
    super.key,
    required this.moduleIdList,
    this.strokeWidth = 1.4,
    this.strokeRadius = 5,
    this.icon = Icons.play_arrow_rounded,
  });

  // Normalized positions for the 7 hexagons.
  // These define the structure. (0,0) is the center of the grid.
  // Values are multipliers for a unit radius.
  // dx = 1.5 (for side length = radius)
  // dy = sqrt(3)/2 (for side length = radius)
  // Let's assume radius = 1 for normalization here.
  // The distance between centers of adjacent hexagons is 2 * radius * sqrt(3)/2 = radius * sqrt(3) if side length is radius
  // Or, if using a slightly different packing for your existing visual:
  // Let's use simpler relative multipliers for now and adjust.
  // These values might need tweaking for perfect honeycomb packing.
  // (x, y) where x is horizontal offset, y is vertical offset from the center of the whole grid.
  static const List<Offset> _normalizedHexCenters = [
    Offset(0, -1.732),      // 0: Top-Center (sqrt(3))
    Offset(1.5, -0.866),    // 1: Top-Right (1.5, sqrt(3)/2)
    Offset(1.5, 0.866),     // 2: Bottom-Right
    Offset(0, 1.732),       // 3: Bottom-Center
    Offset(-1.5, 0.866),    // 4: Bottom-Left
    Offset(-1.5, -0.866),   // 5: Top-Left
    Offset(0, 0),           // 6: Center
  ];

  // Determine the bounding box of the normalized structure
  // This helps in scaling the entire structure.
  static final Rect _normalizedBounds = () {
    double minX = _normalizedHexCenters.map((p) => p.dx).reduce(min);
    double maxX = _normalizedHexCenters.map((p) => p.dx).reduce(max);
    double minY = _normalizedHexCenters.map((p) => p.dy).reduce(min);
    double maxY = _normalizedHexCenters.map((p) => p.dy).reduce(max);
    // Assuming unit hexagon diameter of 2 (radius 1) for bounding box calc for now
    // The actual hexagon drawing will define its extent.
    // This bounding box is for the centers. We add 1 to each side assuming radius 1 hex.
    return Rect.fromLTRB(minX - 1, minY - 1, maxX + 1, maxY + 1);
  }();


  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        if (moduleIdList.isEmpty) {
          return Center(child: Text(LocalizationService().get("no_modules")));
        }

        if (constraints.maxWidth == 0 || constraints.maxHeight == 0) {
          return const SizedBox.shrink(); // No space to draw
        }

        // --- Calculate Scale and Size ---
        // We want to fit the normalized bounding box into the available constraints.
        // Maintain aspect ratio of the honeycomb structure.

        // For a 1:1 square target, the container should ideally be a square.
        // If not, we fit into the smaller dimension of the constraints,
        // or ensure the structure fits while maintaining its aspect ratio.

        double availableWidth = constraints.maxWidth;
        double availableHeight = constraints.maxHeight;

        // Calculate scale factor to fit normalizedBounds into available space
        double scaleX = availableWidth / _normalizedBounds.width;
        double scaleY = availableHeight / _normalizedBounds.height;
        double scale = min(scaleX, scaleY); // Use the smaller scale to fit entirely

        // The 'size' for each HexagonShape should be based on this scale.
        // If normalized radius is 1, then scaled diameter is 2 * scale.
        // This 'hexagonRenderSize' is what you pass to your HexagonShape's size parameter.
        // It represents the characteristic dimension of the hexagon (e.g., vertex-to-vertex diameter).
        double hexagonRenderSize = 1.9 * scale; // Assuming normalized radius was 1

        // If your HexagonShape's 'size' parameter means something else (e.g. side length), adjust this.
        // Let's assume 'size' for HexagonShape is its outer diameter (vertex-to-vertex).

        // If hexagonRenderSize becomes too small, you might want a minimum size or hide the grid.
        if (hexagonRenderSize < 20.0) { // Example minimum size
          // return Center(child: Text(LocalizationService().get("too_small_to_display_modules")));
          // Or adjust behavior, e.g. show fewer items if possible, or a simplified view
        }

        // --- Build Hexagons ---
        List<Widget> hexagons = [];
        for (int i = 0; i < 7; i++) {
          if (i >= moduleIdList.length && i != 6) { // Always show center if possible, or handle differently
            // Potentially add disabled-looking hexagons for empty slots later
            // For now, only build if moduleId exists, or if it's the center placeholder
          }

          Offset normalizedCenter = _normalizedHexCenters[i];

          // Calculate actual center position within the LayoutBuilder's constraints
          // (0,0) of LayoutBuilder is top-left.
          // We need to translate so (0,0) of normalized grid is at the center of LayoutBuilder.
          double actualX = (availableWidth / 2) + (normalizedCenter.dx * scale);
          double actualY = (availableHeight / 2) + (normalizedCenter.dy * scale);


          hexagons.add(
            Positioned(
              // Positioned's left/top are relative to the Stack.
              // The hexagon's center should be at actualX, actualY.
              // So, top-left of the hexagon widget is actualCenter - hexagonRadius.
              left: actualX - (hexagonRenderSize / 2),
              top: actualY - (hexagonRenderSize / 2),
              child: _buildHexagonButton(context, i, hexagonRenderSize),
            ),
          );
        }

        return Stack(
          children: hexagons,
        );
      },
    );
  }

  Widget _buildHexagonButton(BuildContext context, int index, double currentHexSize) {
    bool isIndexAvailable = index >=0 && index < moduleIdList.length;

    return GestureDetector(
      onTap: () {
        if (isIndexAvailable) {
          moduleNavigator.currentState!.pushNamed(Routes.routeChapters, arguments: moduleIdList[index]);
        } else {
          log.warning('No Module Available for hexagon index $index');
        }
      },
      child: HexagonShape(
        size: currentHexSize, // Use the dynamically calculated size
        fillColor: isIndexAvailable ? Theme.of(context).primaryColorLight : Theme.of(context).disabledColor,
        strokeColor: isIndexAvailable ? Theme.of(context).primaryColorDark : Theme.of(context).highlightColor,
        strokeWidth: strokeWidth,
        strokeRadius: strokeRadius,
        icon: icon,
        iconColor: isIndexAvailable ? Theme.of(context).primaryColorDark : Theme.of(context).highlightColor,
        iconSize: currentHexSize / 1.5, // Make icon size relative to hexagon size
        iconText: Text( // Text also needs to scale
          (index + 1).toString(),
          style: TextStyle(
            color: isIndexAvailable ? Theme.of(context).primaryColorLight : Theme.of(context).disabledColor,
            fontSize: currentHexSize / 10, // Make font size relative to hexagon size
          ),
        ),
      ),
    );
  }
}