import 'package:flutter/material.dart';

import '../../common/primitives/envelope.dart';
import '../../common/primitives/point.dart';
import '../../common/primitives/polygon.dart';
import '../../common/primitives/segment.dart';
import '../../utils/math.dart';

class Marking extends CustomPainter {
  Marking(
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
  }

  final Point center;
  final Point directionVector;
  final double width;
  final double height;

  late Segment support;
  late Polygon polygon;

  @override
  void paint(Canvas canvas, Size size) {
    polygon.paint(canvas, size);
  }

  @override
  bool shouldRepaint(covariant Marking oldDelegate) => true;
}
