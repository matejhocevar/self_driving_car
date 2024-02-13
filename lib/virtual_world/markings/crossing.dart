import 'package:flutter/material.dart';

import '../../common/primitives/point.dart';
import '../../common/primitives/segment.dart';
import '../../utils/math.dart';
import 'marking.dart';

class Crossing extends Marking {
  Crossing(
    Point center,
    Point directionVector, {
    double width = 20,
    double height = 10,
  }) : super(center, directionVector, width: width, height: height) {
    borders = [polygon.segments[0], polygon.segments[2]];
  }

  late List<Segment> borders;

  @override
  void paint(Canvas canvas, Size size) {
    Point perp = perpendicular(directionVector);
    Segment line = Segment(
      add(center, scale(perp, width / 2)),
      add(center, scale(perp, -width / 2)),
    );

    line.paint(
      canvas,
      size,
      width: height,
      color: Colors.white,
      dash: [11, 11],
      showPartialDash: true,
    );
  }

  @override
  bool shouldRepaint(covariant Crossing oldDelegate) =>
      center != oldDelegate.center ||
      directionVector != oldDelegate.directionVector ||
      width != oldDelegate.width ||
      height != oldDelegate.height;
}
