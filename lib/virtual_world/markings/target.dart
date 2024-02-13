import 'package:flutter/material.dart';

import '../../common/primitives/point.dart';
import 'marking.dart';

class Target extends Marking {
  Target(
    Point center,
    Point directionVector, {
    double width = 20,
    double height = 10,
  }) : super(center, directionVector, width: width, height: height);

  @override
  void paint(Canvas canvas, Size size) {
    center.paint(canvas, size, color: Colors.red, radius: 16);
    center.paint(canvas, size, color: Colors.white, radius: 10);
    center.paint(canvas, size, color: Colors.red, radius: 6);
  }

  @override
  bool shouldRepaint(covariant Target oldDelegate) =>
      center != oldDelegate.center ||
      directionVector != oldDelegate.directionVector ||
      width != oldDelegate.width ||
      height != oldDelegate.height;
}
