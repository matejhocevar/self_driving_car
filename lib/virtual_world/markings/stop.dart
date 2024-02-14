import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../common/primitives/point.dart';
import '../../utils/math.dart';
import 'marking.dart';

class Stop extends Marking {
  Stop(
    Point center,
    Point directionVector, {
    double width = 20,
    double height = 10,
  }) : super(
          MarkingType.stop,
          center,
          directionVector,
          width: width,
          height: height,
        ) {
    super.borders = [polygon.segments[2]];
  }

  @override
  void paint(Canvas canvas, Size size) {
    borders.first.paint(canvas, size, width: 5, color: Colors.white);

    canvas.save();

    canvas.translate(center.x, center.y);
    canvas.rotate(angle(directionVector) - math.pi / 2);
    canvas.scale(1, 3);
    final TextPainter textPainter = TextPainter(
        text: TextSpan(
          text: "STOP",
          style: TextStyle(
            color: Colors.white,
            fontSize: height * 0.25,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr)
      ..layout(maxWidth: 62);
    textPainter.paint(canvas, const Offset(-16, -7));

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant Stop oldDelegate) =>
      center != oldDelegate.center ||
      directionVector != oldDelegate.directionVector ||
      width != oldDelegate.width ||
      height != oldDelegate.height;
}
