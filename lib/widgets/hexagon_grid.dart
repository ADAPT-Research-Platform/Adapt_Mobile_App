import 'dart:math';

import 'package:flutter/material.dart';
import 'hexagon_shape.dart';

class HexagonGrid extends StatelessWidget {
  final int rows;
  final int cols;
  final double size;
  final Color fillColor;
  final Color strokeColor;
  final double strokeWidth;
  final double strokeRadius;
  final IconData? icon;
  final Color? iconColor;

  const HexagonGrid({
    super.key,
    required this.rows,
    required this.cols,
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
    return LayoutBuilder(
      builder: (context, constraints) {
        List<Widget> hexagons = [];

        for (int row = 0; row < rows; row++) {
          for (int col = 0; col < cols; col++) {

            final offsetX = (row % 2 == 1) ? col * (size + size * cos(pi/3) - strokeWidth) : (col + 1/2) * (size + size * cos(pi/3) - strokeWidth);
            final offsetY = row * (size / 2 * cos(pi/6) - strokeWidth);

            hexagons.add(Positioned(
              left: offsetX,
              top: offsetY,
              child: HexagonShape(
                size: size,
                fillColor: fillColor,
                strokeColor: strokeColor,
                strokeWidth: strokeWidth,
                strokeRadius: strokeRadius,
                icon: icon,
                iconColor: iconColor,
              ),
            ));
          }
        }

        return SizedBox(
          width: constraints.maxWidth,
          height: constraints.maxHeight,
          child: Stack(
            children: hexagons,
          ),
        );
      },
    );
  }
}
