import 'package:flutter/material.dart';
import 'package:flutter_polygon/flutter_polygon.dart';

class HexagonShape extends StatelessWidget {
  final double size;
  final Color fillColor;
  final Color strokeColor;
  final double strokeWidth;
  final double strokeRadius;
  final IconData? icon;
  final Color? iconColor;
  final double? iconSize;
  final Text? iconText;

  const HexagonShape({
    super.key,
    required this.size,
    required this.fillColor,
    this.strokeColor = Colors.transparent,
    this.strokeWidth = 0,
    this.strokeRadius = 0,
    this.icon,
    this.iconColor,
    this.iconSize,
    this.iconText,
  });

  @override
  Widget build(BuildContext context) {
    double iconSize = (this.iconSize != null) ? this.iconSize! : size / 2;

    return Container(
      width: size,
      height: size,
      decoration: ShapeDecoration(
          color: fillColor,
          shape: PolygonBorder(
            sides: 6,
            borderRadius: strokeRadius,
            rotate: 90,
            side: BorderSide(
                color: strokeColor,
                width: strokeWidth,
                strokeAlign: BorderSide.strokeAlignInside
            ),
          )),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(
            icon,
            color: iconColor,
            size: iconSize, // Adjust size as needed
          ),
          if (iconText != null)
            Positioned(
              child: iconText!
            ),
        ],
      ),
    );
  }
}
