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

  const HexagonShape({
    super.key,
    required this.size,
    required this.fillColor,
    this.strokeColor = Colors.transparent,
    this.strokeWidth = 0,
    this.strokeRadius = 0,
    this.icon,
    this.iconColor
  });

  @override
  Widget build(BuildContext context) {
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
      child: Center(
        child: Icon(
          icon,
          color: iconColor,
          size: size / 2,
        ),
      ),
    );
  }
}
