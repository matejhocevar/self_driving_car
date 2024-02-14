import 'package:flutter/material.dart';

import '../../common/primitives/point.dart';
import '../../common/primitives/segment.dart';
import '../../utils/math.dart';
import 'marking.dart';

class Parking extends Marking {
  Parking(
    Point center,
    Point directionVector, {
    double width = 20,
    double height = 10,
  }) : super(
          MarkingType.parking,
          center,
          directionVector,
          width: width,
          height: height,
        ) {
    super.borders = [polygon.segments[0], polygon.segments[2]];
  }

  @override
  void paint(Canvas canvas, Size size) {
    for (Segment b in borders) {
      b.paint(canvas, size, width: 5, color: Colors.white);
    }

    canvas.save();

    canvas.translate(center.x, center.y);
    canvas.rotate(angle(directionVector));
    final TextPainter textPainter = TextPainter(
        text: TextSpan(
          text: "P",
          style: TextStyle(
            color: Colors.white,
            fontSize: height * 0.9,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr)
      ..layout(maxWidth: 20);
    textPainter.paint(canvas, const Offset(-16, -26));

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant Parking oldDelegate) =>
      center != oldDelegate.center ||
      directionVector != oldDelegate.directionVector ||
      width != oldDelegate.width ||
      height != oldDelegate.height;
}
