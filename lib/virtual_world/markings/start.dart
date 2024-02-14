import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../common/primitives/point.dart';
import '../../common/vehicle.dart';
import '../../utils/math.dart';
import 'marking.dart';

class Start extends Marking {
  Start(
    Point center,
    Point directionVector,
    this.vehicle, {
    double width = 20,
    double height = 10,
  }) : super(
          MarkingType.start,
          center,
          directionVector,
          width: width,
          height: height,
          extras: {'vehicle': vehicle.name},
        );

  final Vehicle vehicle;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();

    canvas.translate(center.x, center.y);
    canvas.rotate(angle(directionVector) - math.pi / 2);

    paintImage(
      canvas: canvas,
      rect: Rect.fromPoints(
        Offset(-width / 2, -height / 2),
        Offset(width / 2, height / 2),
      ),
      image: vehicle.image!,
      fit: BoxFit.scaleDown,
      opacity: 1,
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant Start oldDelegate) =>
      center != oldDelegate.center ||
      directionVector != oldDelegate.directionVector ||
      vehicle != oldDelegate.vehicle ||
      width != oldDelegate.width ||
      height != oldDelegate.height;
}
