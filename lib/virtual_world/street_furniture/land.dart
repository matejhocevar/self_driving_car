import 'package:flutter/material.dart';

import '../../common/primitives/polygon.dart';
import '../settings.dart';

enum LandType {
  unknown,
  water,
  green,
  farmland,
  forest,
  orchard,
  tundra,
  beach,
  snow,
  rock,
  volcano,
}

class Land extends CustomPainter {
  const Land(this.polygon, {this.type = LandType.unknown});

  final Polygon polygon;
  final LandType type;

  @override
  void paint(Canvas canvas, Size size, {double? lineWidth}) {
    polygon.paint(
      canvas,
      size,
      fill: VirtualWorldSettings.landsColor(type) ??
          VirtualWorldSettings.landsColor(LandType.unknown),
      lineWidth: lineWidth ?? 0,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
