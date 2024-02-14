import 'package:flutter/material.dart';

import '../../common/primitives/point.dart';
import '../../common/primitives/segment.dart';
import '../../utils/math.dart';
import 'marking.dart';

enum TrafficLightState {
  off,
  red,
  yellow,
  green,
}

class TrafficLight extends Marking {
  TrafficLight(
    Point center,
    Point directionVector, {
    double width = 20,
    double height = 20,
  }) : super(
          MarkingType.trafficLight,
          center,
          directionVector,
          width: width,
          height: 18,
        ) {
    super.borders = [polygon.segments[0]];
  }

  TrafficLightState state = TrafficLightState.off;

  @override
  void paint(Canvas canvas, Size size) {
    Point perp = perpendicular(directionVector);
    Segment line = Segment(
      add(center, scale(perp, width / 2)),
      add(center, scale(perp, -width / 2)),
    );

    Point green = lerp2D(line.p1, line.p2, 0.2);
    Point yellow = lerp2D(line.p1, line.p2, 0.5);
    Point red = lerp2D(line.p1, line.p2, 0.8);

    Segment(red, green).paint(
      canvas,
      size,
      width: height,
      strokeCap: StrokeCap.round,
    );

    switch (state) {
      case TrafficLightState.green:
        {
          green.paint(canvas, size, radius: height * 0.3, color: Colors.green);
          break;
        }
      case TrafficLightState.yellow:
        {
          yellow.paint(canvas, size,
              radius: height * 0.3, color: Colors.yellow);
          break;
        }
      case TrafficLightState.red:
        {
          red.paint(canvas, size, radius: height * 0.3, color: Colors.red);
          break;
        }
      case TrafficLightState.off:
      default:
        break;
    }
  }

  @override
  bool shouldRepaint(covariant TrafficLight oldDelegate) =>
      center != oldDelegate.center ||
      directionVector != oldDelegate.directionVector ||
      width != oldDelegate.width ||
      height != oldDelegate.height;
}
