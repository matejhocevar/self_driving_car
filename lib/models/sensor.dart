import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../utils/math.dart';
import 'car.dart';
import 'math.dart';

class Sensor {
  Sensor({
    required this.car,
    this.rayCount = 3,
    this.rayLength = 100,
    this.raySpread = math.pi / 4,
  });

  final Car car;
  final int rayCount;
  final double rayLength;
  final double raySpread;

  List<List<Offset>> rays = [];
  List readings = [];

  void update(List<List<Offset>> roadBorders) {
    _castRays();

    readings = [];
    for (int i = 0; i < rays.length; i++) {
      readings.add(
        _getReading(rays[i], roadBorders),
      );
    }
  }

  void _castRays() {
    rays = [];
    for (int i = 0; i < rayCount; i++) {
      double rayAngle = lerp(
            raySpread / 2,
            -raySpread / 2,
            rayCount == 1 ? 0.5 : i / (rayCount - 1),
          ) +
          car.angle;

      var start = Offset(car.x, car.y);
      var end = Offset(
        car.x - math.sin(rayAngle) * rayLength,
        car.y - math.cos(rayAngle) * rayLength,
      );
      rays.add([start, end]);
    }
  }

  Position? _getReading(List<Offset> ray, List<List<Offset>> roadBorders) {
    final [rayStart, rayEnd] = ray;

    List<Position> touches = [];
    for (int i = 0; i < roadBorders.length; i++) {
      final [borderStart, borderEnd] = roadBorders[i];
      Position? touch = getIntersection(
        rayStart,
        rayEnd,
        borderStart,
        borderEnd,
      );

      if (touch != null) {
        touches.add(touch);
      }
    }

    if (touches.isEmpty) {
      return null;
    }
    var offsets = touches.map((Position p) => p.offset);
    double minOffset = offsets.reduce(math.min);
    return touches.firstWhere((Position p) => p.offset == minOffset);
  }
}
