import 'package:flutter/material.dart';

import '../../common/primitives/envelope.dart';
import '../../common/primitives/point.dart';
import '../../common/primitives/polygon.dart';
import '../../common/primitives/segment.dart';
import '../../utils/math.dart';
import 'marking.dart';

class Crossing implements Marking {
  Crossing(
    this.center,
    this.directionVector, {
    this.width = 20,
    this.height = 10,
  }) {
    support = Segment(
      translate(center, angle(directionVector), height / 2),
      translate(center, angle(directionVector), -height / 2),
    );
    polygon = Envelope(support, width: width).polygon;
    borders = [polygon.segments[0], polygon.segments[2]];
  }

  final Point center;
  final Point directionVector;
  final double width;
  final double height;

  late Segment support;
  late List<Segment> borders;
  @override
  late Polygon polygon;

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
